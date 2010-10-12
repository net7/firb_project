# Represents a throne (trono), which is part of a card in
# the FIRB FI parade
class FiThroneCard < IllustrationCard

  single_property :cart, N::TALIA.cart, :type => TaliaCore::ActiveSource
  
end