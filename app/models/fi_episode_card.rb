# An episode that is part of a vehicle in the FIRB FI parade
class FiEpisodeCard < IllustrationCard

  include FiCardsCommonFields
  extend FiCardsCommonFields::DefinedProperties

  common_properties
  autofill_uri :force => true

  singular_property :vehicle, N::TALIA.vehicle, :type => TaliaCore::ActiveSource
  
end