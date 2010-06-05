class FirbFiTextCard < FirbTextCard

  hobo_model
  include StandardPermissions

  rdf_property :title, N::DCNS.title

  # Edizione di riferimento
  rdf_property :edition, N::TALIA.edition, :force_relation => true

  # Numero pagina
  rdf_property :page_position, N::TALIA.position

  fields do
    uri :string
  end
  
end