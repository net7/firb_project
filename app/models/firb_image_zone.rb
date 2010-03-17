class FirbImageZone < FirbImageElement
  hobo_model # Don't put anything above this
  
  fields do
    uri :string
  end
  
  declare_attr_type :name, :string
  
  def uri
    self[:uri]
  end
  
  set_table_name "active_sources"

  def name=(name)
    self.uri = (N::LOCAL + name).to_s
  end
  
  def name
    self.uri.nil? ? nil : self.uri.to_uri.local_name
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