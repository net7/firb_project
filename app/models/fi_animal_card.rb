# This represent the animal(s) which are part of 
# a cart in the FIRB FI parade
class FiAnimalCard < IllustrationCard

  singular_property :cart, N::TALIA.cart, :type => TaliaCore::ActiveSource
  
end