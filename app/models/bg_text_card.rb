class BgTextCard < TextCard

  hobo_model
  include StandardPermissions

  rdf_property :title, N::DCNS.title

  # Link all'anastatica
  singular_property :anastatica, N::DCT.isPartOf, :force_relation => true

  # Numero carta
  rdf_property :page_position, N::TALIA.position

  # Collocazione
  rdf_property :collocation, N::TALIA.provenance

  # Segnatura
  rdf_property :signature, N::TALIA.signature

  # Autore
  rdf_property :author, N::DCT.creator

  # Commento
  rdf_property :comment, N::TALIA.comment, :type => 'text'

  fields do
    uri :string
  end
  
end