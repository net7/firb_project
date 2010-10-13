# This represent the animal(s) which are part of 
# a cart in the FIRB FI parade
class FiAnimalCard < IllustrationCard

  include FiCardsCommonFields
  extend FiCardsCommonFields::DefinedProperties

  common_properties
  autofill_uri :force => true

  singular_property :cart, N::TALIA.cart, :type => TaliaCore::ActiveSource
  
end