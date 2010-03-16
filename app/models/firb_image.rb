class FirbImage < TaliaCore::Source
  hobo_model # Don't put anything above this
  
  has_many :FirbImageZones
  
  fields do
    uri :string
  end
  
  declare_attr_type :name, :string
  
  def uri
    self[:uri]
  end
  
  # Creates an Image object from the given file, using the given name
  def self.create(name, file)
    logger.info "@@ called create with #{name} and #{file}"
    @me = FirbImage.new();
    @me.attach_file(file);
    @me.name = name;
    @me.save()
    @me
  end
  
  # Loads a file into this object. This may delay the actual processing into
  # a background task. #file_attached? can be used to check if the file has
  # already been loaded.
  def attach_file(tmp_file)
    logger.info "@@ called attach_file with #{tmp_file}"
  end
  
  # Checks if a file is attached to the image. This can also be used to see
  # if the file has already been attached by a background task
  def file_attached?
  end
  
  # Returns the XML for the "Zones" polygons. This returns an XML which can be
  # passed to the Image Mapper Tool
  def zones_xml
  end
  
  # Updates all zones from the given XML file (from the Image Mapper Tool)
  def update_zones(xml)
  end

  def zone_count
    zones.count
  end
  
  def zones
    qry = ActiveRDF::Query.new(FirbImageZone).select(:z).distinct
    qry.where(:z, N::TALIA.isPartOf, self)
    qry.execute
  end
  
  # Adds a new, empty zone. If a parent is given, this will be a child of
  # the named parent zone (the parent will be identified by the zone name)
  def add_zone(name, parent_name = nil)
    logger.info "@@ called add_zone with #{name} (parent #{parent_name})"
    @zone = FirbImageZone.new
    @zone.name = "#{self.name}__#{name}"
    @zone[N::TALIA.isPartOf] << self
    @zone.save()
  end
  
  # Deletes the name zone
  def delete_zone(name)
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