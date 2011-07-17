# Pi illustration Card: scheda illustrazione (Firb Pi)
class PiIllustrationCard < IllustrationCard

  include StandardPermissions
  extend Mixin::ShownInAnastatica
  
  autofill_uri :force => true
  
  # Short description: brief desc. of the depiction, say "Male person
  # drawing"
  singular_property :short_description, N::TALIA.short_description
  declare_attr_type :short_description, :text
   
  fields do
    uri :string
  end  
end
