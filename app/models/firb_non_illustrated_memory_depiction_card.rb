class FirbNonIllustratedMemoryDepictionCard < FirbCard
  
  include StandardPermissions
  extend RdfProperties
  
  # Short description: brief desc. of the depiction, say "Male person
  # drawing"
  rdf_property :short_description, N::TALIA.short_description, :type => :text
  rdf_property :depiction_type, N::TALIA.depiction_type # Type of the depiction
  

end