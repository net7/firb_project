class ImageComponent < TaliaCore::Source
  hobo_model # Don't put anything above this
  include StandardPermissions
  extend RdfProperties
  
  autofill_uri :force => true
  
  rdf_property :name, N::TALIA.name
  rdf_property :zone_type, N::DCT.type
  rdf_property :image_zone, N::TALIA.image_zone, :force_relation => true
  
end