class VtPrintedTextCard < TextCard

  hobo_model
  include StandardPermissions

  singular_property :anastatica, N::DCT.isPartOf, :type => TaliaCore::ActiveSource
  rdf_property :title, N::DCNS.title
  multi_property :image_zones, N::DCT.isFormatOf, :type => TaliaCore::ActiveSource

  # Link a trascrizione diplomatica e trascrizione versione a stampa
  rdf_property :transc_diplomatic, N::TALIA.transcription_diplomatic, :type => TaliaCore::ActiveSource
  rdf_property :transc_handwritten, N::TALIA.transcription_handwritten, :type => TaliaCore::ActiveSource

  # Numero pagina
  rdf_property :page_position, N::TALIA.position
  
  # Numero lettera
  rdf_property :letter_number, N::TALIA.letter_number

  # Collocazione
  rdf_property :collocation, N::TALIA.provenance
  
  # Edizione di riferimento
  rdf_property :edition, N::TALIA.edition, :type => TaliaCore::ActiveSource

  # Bibliografia
  multi_property :bibliography_items, N::TALIA.hasBibliography, :type => TaliaCore::ActiveSource
  
  fields do
    uri :string
  end
  
end