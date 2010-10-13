# Represents a throne (trono), which is part of a card in
# the FIRB FI parade
class FiThroneCard < IllustrationCard

  singular_property :cart, N::TALIA.cart, :type => TaliaCore::ActiveSource
  
end