class FirbIllustratedMemoryDepictionCard < FirbIllustrationCard
  
  include StandardPermissions
  
  # Short description: brief desc. of the depiction, say "Male person
  # drawing"
  singular_property :short_description, N::TALIA.short_description
  declare_attr_type :short_description, :text
  singular_property :transcription_text, N::TALIA.transcription
  declare_attr_type :transcription_text, :text
  singular_property :parent_card, N::TALIA.parent_card

  # Still missing:
  # textual source: link to a text page
  # links to component depictions pages
  
  def self.setup_options!(options)
    options.to_options!
    options[N::TALIA.image_component.to_s] = options.delete(:image_component).to_a.collect { |ic| FirbImageZone.find(ic) }
    super(options)
  end
  
end