class FirbLetterIllustrationPage < FirbIllustrationPage
  hobo_model # Don't put anything above this
  include StandardPermissions
  
  fields do
    uri :string
  end
  
  # TODO: Shared from the superclass
  declare_attr_type :code, :string
  declare_attr_type :collocation, :string
  declare_attr_type :tecnique, :string
  declare_attr_type :measure, :text
  declare_attr_type :position, :string
  declare_attr_type :descriptive_notes, :text
  declare_attr_type :study_notes, :text
  declare_attr_type :description, :text
  declare_attr_type :completed, :boolean

  # Missing: 
  # list of decorative components, with: name, type (floreal, human, ..)
  # illustration's components
  
end