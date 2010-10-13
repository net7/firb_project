# Represents the vehicle that is part of a whole cart in the
# FIRB FI parade. 
class FiVehicleCard < IllustrationCard

  include FiCardsCommonFields
  extend FiCardsCommonFields::DefinedProperties

  common_properties
  autofill_uri :force => true

  singular_property :cart, N::TALIA.cart, :type => TaliaCore::ActiveSource

end