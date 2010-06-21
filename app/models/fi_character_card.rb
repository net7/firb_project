# Represents a character in the FIRB FI parade. A character may or may not be related
# to a cart
class FiCharacterCard < IllustrationCard
  
  autofill_uri
  
  include FiCardsCommonFields
  extend FiCardsCommonFields::DefinedProperties
  
  common_properties
  
  singular_property :cart, N::TALIA.cart, :force_relation => true
  rdf_property :character_qualities, N::TALIA.character_qualities, :type => :text
  
end