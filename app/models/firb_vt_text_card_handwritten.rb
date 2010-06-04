  class FirbVtTextCardHandwritten < FirbTextCard

  hobo_model

  singular_property :anastatica, N::DCT.isPartOf, :force_relation => true
  rdf_property :title, N::DCNS.title
  multi_property :image_zones, N::DCT.isFormatOf, :force_relation => true

  # Link a trascrizione diplomatica e trascrizione versione a stampa
  rdf_property :transc_diplomatic, N::TALIA.transcription_diplomatic, :force_relation => true
  rdf_property :transc_printed, N::TALIA.transcription_printed, :force_relation => true
  
  # Segnatura
  rdf_property :signature, N::TALIA.signature

  # Misure
  rdf_property :measure, N::TALIA.measure

  # Filigrana
  rdf_property :watermark, N::TALIA.watermark
  
  # Cartulazione
  rdf_property :cartulation, N::TALIA.cartulation

  # Note tecniche
  rdf_property :technical_notes, N::TALIA.techical_notes, :type => 'text'
  
  # Altre note manoscritte
  rdf_property :handwritten_notes, N::TALIA.handwritten_notes, :type => 'text'
  
  # Stato di conservazione
  rdf_property :conservation_status, N::TALIA.conservation_status
  
  # Autografia
  rdf_property :autography, N::TALIA.autography
  
  # Data 
  rdf_property :date, N::DCT.date

  # Bibliografia
  multi_property :bibliography_items, N::TALIA.hasBibliography, :force_relation => true
  
  
  fields do
    uri :string
  end
  
end