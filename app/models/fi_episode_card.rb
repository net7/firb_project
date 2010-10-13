# An episode that is part of a vehicle in the FIRB FI parade
class FiEpisodeCard < IllustrationCard

  singular_property :vehicle, N::TALIA.vehicle, :type => TaliaCore::ActiveSource
  
end