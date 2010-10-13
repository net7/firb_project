# This is represents a deity (divinta'), which is part of
# a cart in the FIRB FI parade
class FiDeityCard < IllustrationCard

  include FiCardsCommonFields
  extend FiCardsCommonFields::DefinedProperties

  common_properties
  autofill_uri :force => true

  singular_property :cart, N::TALIA.cart, :type => TaliaCore::ActiveSource
  
end