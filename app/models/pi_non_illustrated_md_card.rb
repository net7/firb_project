# Non illustrated memory depiction card: immagini di memoria non illustrate (firb PI)
# Used as part of PI text cards
class PiNonIllustratedMdCard < BaseCard
  
  include StandardPermissions
  extend RdfProperties
  
  autofill_uri :force => new
  
  # Short description: brief desc. of the depiction, say "Male person drawing"
  rdf_property :short_description, N::TALIA.short_description, :type => :text
  rdf_property :depiction_type, N::TALIA.depiction_type # Type of the depiction

end
