require 'fileutils'
require 'digest/md5'

class FirbImage < FirbImageElement
  hobo_model # Don't put anything above this

  include StandardPermissions

  # The file status will be originally empty (no file attach) and will be
  # set by the worker process, either to "OK" (successfully attached the file)
  # or to an error message. 
  singular_property :file_status, N::TALIA.file_status

  def self.file_staging_dir
    @file_staging_dir ||=  begin
      staging_dir = File.join(TaliaCore::CONFIG['data_directory_location'], 'staged_images')
      FileUtils.mkdir(staging_dir) unless(File.exist?(staging_dir))
      staging_dir
    end
  end
  
  fields do
    uri :string
  end
  
  declare_attr_type :name, :string

  # Returns the IIP record
  def iip_record
    data_records.find(:first, :conditions => { :type => "TaliaCore::DataTypes::IipData" })
  end
  
  # Returns the Original image record
  # FIXME: Not correct yet!
  def original_image
     data_records.find(:first, :conditions => { :type => "TaliaCore::DataTypes::ImageData" })
  end
  
  # Creates an Image object from the given file, using the given name
  def self.create_with_file(name, file)
    new_url = N::LOCAL + 'images/' + random_id
    raise(ArgumentError, "Record already exists #{new_url}") if(TaliaCore::ActiveSource.exists?(new_url))
    image = self.new(new_url)
    image.name = name
    image.attach_file(file)
    image
  end
  
  # Loads a file into this object. This may delay the actual processing into
  # a background task. #file_attached? can be used to check if the file has
  # already been loaded.
  def attach_file(up_file)
    save! if(self.new_record?)
    staged_file = File.join(self.class.file_staging_dir, Digest::MD5.hexdigest(uri.to_s) + '.jpg')
    if(up_file.is_a?(File))
      File.open(staged_file, 'w') { |f| f << up_file.read }
    else
      FileUtils.copy(up_file, staged_file)
    end
    FirbImageWorker.async_create_image(:image_uri => self.uri, :image_file => staged_file)
  end

end
