# Letter Illustration Card (Firb Pi): scheda capolettera
class PiLetterIllustrationCard < IllustrationCard
  include StandardPermissions
  
  autofill_uri :force => true
  
  # Missing: 
  # list of decorative components, with: name, type (floreal, human, ..)
  # illustration's components
  
end