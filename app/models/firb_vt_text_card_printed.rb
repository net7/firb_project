class FirbVtTextCardPrinted < FirbTextCard

  hobo_model
  include StandardPermissions

  singular_property :anastatica, N::DCT.isPartOf, :force_relation => true
  rdf_property :title, N::DCNS.title
  multi_property :image_zones, N::DCT.isFormatOf, :force_relation => true

  # Link a trascrizione diplomatica e trascrizione versione a stampa
  rdf_property :transc_diplomatic, N::TALIA.transcription_diplomatic, :force_relation => true
  rdf_property :transc_handwritten, N::TALIA.transcription_handwritten, :force_relation => true

  # Numero pagina
  rdf_property :page_position, N::TALIA.position
  
  # Numero lettera
  rdf_property :letter_number, N::TALIA.letter_number

  # Collocazione
  rdf_property :collocation, N::TALIA.provenance
  
  # Edizione di riferimento
  rdf_property :edition, N::TALIA.edition, :force_relation => true

  # Bibliografia
  multi_property :bibliography_items, N::TALIA.hasBibliography, :force_relation => true
  
  fields do
    uri :string
  end
  
end