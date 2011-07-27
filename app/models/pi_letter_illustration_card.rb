# Letter Illustration Card (Firb Pi): scheda capolettera
class PiLetterIllustrationCard < IllustrationCard

  include StandardPermissions
  extend Mixin::Showable
  showable_in Anastatica
  
  autofill_uri :force => true

  # Missing: 
  # list of decorative components, with: name, type (floreal, human, ..)
  # illustration's components
end
