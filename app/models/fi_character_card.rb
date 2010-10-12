# Represents a character in the FIRB FI parade. A character may or may not be following
# a cart. Cart+following characters build a procession. A book is an ordered list of
# processions.
class FiCharacterCard < IllustrationCard
  
  autofill_uri
  
  include FiCardsCommonFields
  extend FiCardsCommonFields::DefinedProperties
  
  common_properties
  
  rdf_property :character_qualities, N::TALIA.character_qualities, :type => :text
  
end