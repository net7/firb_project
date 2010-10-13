# Represents a throne (trono), which is part of a card in
# the FIRB FI parade
class FiThroneCard < IllustrationCard

  include FiCardsCommonFields
  extend FiCardsCommonFields::DefinedProperties

  common_properties
  autofill_uri :force => true

  singular_property :cart, N::TALIA.cart, :type => TaliaCore::ActiveSource
  
end