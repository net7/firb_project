# Represents a Cart (Carro) in the Parade of FIRB FI
class FiParadeCartCard < IllustrationCard
  
  include FiCardsCommonFields
  extend FiCardsCommonFields::DefinedProperties
  
  common_properties
  autofill_uri :force => true
  
  singular_property :vehicle, N::TALIA.vehicle, :type => TaliaCore::ActiveSource
  singular_property :deity, N::TALIA.deity, :type => TaliaCore::ActiveSource
  singular_property :throne, N::TALIA.throne, :type => TaliaCore::ActiveSource
  multi_property :animals, N::TALIA.animal, :type => TaliaCore::ActiveSource
  
end