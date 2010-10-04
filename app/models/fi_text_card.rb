class FiTextCard < TextCard

  hobo_model
  include StandardPermissions

  rdf_property :title, N::DCNS.title

  # Edizione di riferimento
  rdf_property :edition, N::TALIA.edition, :type => TaliaCore::ActiveSource

  # Numero pagina
  rdf_property :page_position, N::TALIA.position

  fields do
    uri :string
  end
      
end