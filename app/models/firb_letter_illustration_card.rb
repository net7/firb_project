class FirbLetterIllustrationCard < FirbIllustrationCard
  include StandardPermissions
  
  autofill_uri :force => true
  
  # Missing: 
  # list of decorative components, with: name, type (floreal, human, ..)
  # illustration's components
  
end