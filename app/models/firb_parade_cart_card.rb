# Represents a Cart (Carro) in the Parade of FIRB FI
class FirbParadeCartCard < FirbIllustrationCard
  
  include FiCardsCommonFields
  extend FiCardsCommonFields::DefinedProperties
  
  common_properties
  autofill_uri :force => true
  
  singular_property :vehicle, N::TALIA.vehicle, :force_relation => true
  singular_property :deity, N::TALIA.deity, :force_relation => true
  singular_property :throne, N::TALIA.throne, :force_relation => true
  multi_property :animals, N::TALIA.animal, :force_relation => true
  
end