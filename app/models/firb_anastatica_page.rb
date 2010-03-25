class FirbAnastaticaPage < TaliaCore::Source
  hobo_model # Don't put anything above this
  include StandardPermissions
  
  singular_property :title, N::DCNS.title
  declare_attr_type :title, :string
  singular_property :page_position, N::TALIA.position
  declare_attr_type :page_position, :string
  
end