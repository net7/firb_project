class FirbIllustratedMemoryDepictionPage < FirbIllustrationPage
  hobo_model # Don't put anything above this
  include StandardPermissions
  
  # Short description: brief desc. of the depiction, say "Male person
  # drawing"
  singular_property :short_description, N::TALIA.short_description
  declare_attr_type :short_description, :text

  # Still missing:
  # textual source: link to a text page
  # links to component depictions pages

  
  fields do
    uri :string
  end
  
end