module RdfProperties
  
  def rdf_property(shortcut, property, type = nil)
    type ||= :string
    singular_property shortcut, property
    declare_attr_type shortcut, type
  end
  
end