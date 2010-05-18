class FirbLetterIllustrationCard < FirbIllustrationCard
  include StandardPermissions
  
  # Missing: 
  # list of decorative components, with: name, type (floreal, human, ..)
  # illustration's components
  
  
  def self.setup_options!(options)
    options.to_options!
    options[N::TALIA.image_component.to_s] = options.delete(:image_component).to_a.collect { |ic| FirbImageZone.find(ic) }
    super(options)
  end
  
end