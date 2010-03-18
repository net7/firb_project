class FirbImageZone < FirbImageElement
  hobo_model # Don't put anything above this
  
  attr_accessor :image
  
  fields do
    uri :string
  end
  
  declare_attr_type :name, :string
  
  # Creates a new zone. You must pass in the image object to which this zone will 
  # be connected. Optionally, you may also pass in a parent zone
  def self.create_with_name(name)
    new_url = N::LOCAL + 'zones/' + random_id
    raise(ArgumentError, "Record already exists #{new_url}") if(TaliaCore::ActiveSource.exists?(new_url))
    zone = self.new(new_url)
    zone.name = name 
    zone
  end
  
  def self.find_by_name(name)
    ActiveRDF::Query.new(FirbImageZone).select(:zone).where(:zone).where(:zone, N::TALIA.name, name).execute.first
  end

  # Returns the XML describing the polygon that this zone contains
  def polygon
  end
  
  # Set the polygon XML for this zone
  def polygon=(xml)
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