# Represents the vehicle that is part of a whole cart in the
# FIRB FI parade. 
class FiVehicleCard < IllustrationCard

  single_property :cart, N::TALIA.cart, :type => TaliaCore::ActiveSource

end