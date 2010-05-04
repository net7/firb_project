class FirbParentIllustrationCard < FirbIllustrationCard
  
  include StandardPermissions
  
  # Short description: brief desc. of the depiction, say "Male person
  # drawing"
  singular_property :short_description, N::TALIA.short_description
  declare_attr_type :short_description, :text
  
  singular_property  :textual_source, N::TALIA.attachedText
   
  fields do
    uri :string
  end
  
  
end