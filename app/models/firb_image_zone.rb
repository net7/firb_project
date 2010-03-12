class FirbImageZone < TaliaCore::Source
  hobo_model # Don't put anything above this
  
  attr_reader :image
  
  fields do
    uri :string
  end
  
  declare_attr_type :name, :string
  
  def uri
    self[:uri]
  end
  
  # Creates a new zone. You must pass in the image object to which this zone will 
  # be connected. Optionally, you may also pass in a parent zone
  def create(name, image, parent = nil)
    @image = image
    self.name = name # also sets the image relation
    image[N::TALIA.hasSubZone] << self
    parent[N::TALIA.hasSubZone] << self if(parent)
  end
  
  # Returns the XML describing the polygon that this zone contains
  def polygon
  end
  
  # Set the polygon XML for this zone
  def polygon=(xml)
  end
  
  # Returns the direct sub-zones of the current zone
  def direct_sub_zones
    ActiveRDF::Query.new(FirbImageZone).select(:zone).where(self, N::TALIA.hasSubZone, :zone).execute
  end
  
  # The image to which this zone is attached
  def image
    @image ||= begin
      image_uri = ActiveRDF::Query.new(N::URI).select(:image).where(:image, N::TALIA.hasZone, self).first
      FirbImage.find(image_uri)
    end
  end
  
  # Sets the name of this Image. '''Attention''': This also modifies
  # the uri of the Source. The name will be stored in the talia:name
  # property. Also resets the relation to the image to which this is connected.
  def name=(name)
    image[N::TALIA.hasZone].remove(self)
    self.uri = (N::LOCAL.images + image.name + '/zones/' + name).to_s
    self[N::TALIA.name].remove
    self[N::TALIA.name] << name
    image[N::TALIA.hasZone] << self
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