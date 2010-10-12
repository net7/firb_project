# Represents a Cart (Carro) in the Parade of FIRB FI
class FiParadeCartCard < IllustrationCard
  
  include FiCardsCommonFields
  extend FiCardsCommonFields::DefinedProperties
  
  common_properties
  autofill_uri :force => true

end