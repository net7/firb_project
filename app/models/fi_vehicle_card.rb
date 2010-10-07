# Represents the vehicle that is part of a whole cart in the
# FIRB FI parade. 
class FiVehicleCard < IllustrationCard

  multi_property :episodes, N::TALIA.episode, :type => TaliaCore::ActiveSource

end