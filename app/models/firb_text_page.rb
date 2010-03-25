class FirbTextPage < TaliaCore::Source
  hobo_model # Don't put anything above this
  
  include StandardPermissions
  
  # These are single-value properties, the system will make sure
  # that there is only one value at a time
  singular_property :title, N::DCNS.title
  singular_property :parafrasi, N::DCT.description
  
  fields do
    uri :string
  end

  # Declare methods (getter/setter pairs) that should be used as
  # fields by hobo. The type will be used by the automatic 
  # forms to decide the input type.
  declare_attr_type :title, :string
  declare_attr_type :parafrasi, :text
  
  # Multi-value stuff:
  # - No direct support through hobo as a field 
  # - you can use the page.namespace:name notation
  
  
end