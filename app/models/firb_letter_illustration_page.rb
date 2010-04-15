class FirbLetterIllustrationPage < FirbIllustrationPage
  hobo_model # Don't put anything above this
  include StandardPermissions
  
  fields do
    uri :string
  end

  # Missing: 
  # list of decorative components, with: name, type (floreal, human, ..)
  # illustration's components
  
end