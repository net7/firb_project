require 'fileutils'
require 'digest/md5'

class FirbImage < FirbImageElement
  hobo_model # Don't put anything above this

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
  
  def uri
    self[:uri]
  end
  
  # Creates an Image object from the given file, using the given name
  def self.create(name, file)
    self.name = name
    attach_file(file)
  end
  
  # Loads a file into this object. This may delay the actual processing into
  # a background task. #file_attached? can be used to check if the file has
  # already been loaded.
  def attach_file(up_file)
    staged_file = File.join(self.class.staging_dir, Digest::MD5.hexdigest(self[:uri]))
    FileUtils.move(up_file, staged_file)
    FirbImageWorker.async_create_image(:image_uri = self.uri, :image_file = staged_file)
  end
  
  # Checks if a file is attached to the image. This can also be used to see
  # if the file has already been attached by a background task
  def file_attached?
    !(self.data(TaliaCore::DataTypes::ImageData).empty?)
  end
   
  # Returns the XML for the "Zones" polygons. This returns an XML which can be
  # passed to the Image Mapper Tool
  def zones_xml
  end
  
  # Updates all zones from the given XML file (from the Image Mapper Tool)
  def update_zones(xml)
  end

  # Adds a new, empty zone. If a parent is given, this will be a child of
  # the named parent zone (the parent will be identified by the zone name)
  def add_zone(name, parent_name = nil)
    zone = FirbImageZone.create(name, self, FirbImageZone)
    zone.save!
  end
  
  # Deletes the name zone
  def delete_zone(name)
    FirbImageZone.find((N::LOCAL.images + self.name + '/zones/' + name).to_s).destroy
  end
  
  # Returns the first-level zones of the image (not the sub-zones). Sub-zones
  # can be accessed by calling #sub_zones on each zone object recursively
  def direct_zones
    ActiveRDF::Query.new(FirbImageZone).select(:zone).where(self, N::TALIA.hasSubZone, :zone).execute
  end
  
  # Sets the name of this Image. '''Attention''': This also modifies
  # the uri of the Source. The name will be stored in the talia:name
  # property.  
  def name=(name)
    self.uri = (N::LOCAL.images + name).to_s
    self[N::TALIA.name].remove
    self[N::TALIA.name] << name
  end
  
  def name
    self[N::TALIA.name].first
  end
  
  def create_permitted?
    acting_user.administrator?
  end
  
  def update_permitted?
    acting_user.administrator?
  end
  
  def view_permitted?(field)
    acting_user.signed_up?
  end

end
