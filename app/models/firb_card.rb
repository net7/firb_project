class FirbCard < TaliaCore::Source
  hobo_model # Don't put anything above this
  
  include StandardPermissions
  
  singular_property :name, N::TALIA.name
  declare_attr_type :name, :string
  
  extend RandomId

  # Anastatica page it links to
  singular_property :anastatica, N::DCT.isPartOf

  # Code: internal identifier used by the owner of the original source
  # to archive it
  singular_property :code, N::TALIA.identifier
  declare_attr_type :code, :string

  # Collocation: phisical place where the original manuscript
  # (or, in general, the original source) can be found or is conserved
  singular_property :collocation, N::TALIA.provenance
  declare_attr_type :collocation, :string
  
  # Tecnique: used to describe the way the image has been drawn
  # say: "oil on paper" or "pencil on wood"
  singular_property :tecnique, N::TALIA.tecnique
  declare_attr_type :tecnique, :string
  
  # Measure: describes the phisical dimensions of the depiction
  # usually in centimeters
  singular_property :measure, N::TALIA.measure
  declare_attr_type :measure, :string
  
  # Position: describes the position of the depiction inside the
  # "big picture", say "upper left corner" or "bottom part"
  singular_property :position, N::DCT.position
  declare_attr_type :position, :string
  
  # Descriptive notes: some notes which describes the depiction, meant to
  # be a kinf of appendix of the description field
  singular_property :descriptive_notes, N::TALIA.descriptive_notes
  declare_attr_type :descriptive_notes, :text
  
  # Study notes: some informations about the illustration, say "four depictions
  # are positioned clockwise in the four corners of a room with gray floor
  # and green walls. The fifth depiction is positioned between the door and
  # and the fourth depiction"
  singular_property :study_notes, N::TALIA.study_notes
  declare_attr_type :study_notes, :text
  
  # Description: long description of the depiction, say "Male person
  # dressed in green and red, with a white hat and long brown hair, is
  # using his left hand to draw while the right one is keeping a cross on
  # his chest"
  singular_property :description, N::TALIA.description
  declare_attr_type :description, :text
  
  # Completed: true if the illustration is fully completed or false if
  # say some colors are not on their place or some parts are only sketched
  singular_property :completed, N::TALIA.completed
  declare_attr_type :completed, :boolean
  
  fields do
    uri :string
  end
  
  def bibliography_items
    self[N::TALIA.hasBibliography]
  end

  def has_anastatica_page?
    !self.anastatica.blank?
  end

  def rewrite_attributes!(options = {})
    setup_options!(options)
    super(options)
  end

  def child_cards
    ActiveRDF::Query.new(FirbCard).select(:card).where(:card, N::DCT.isPartOf, self).execute
  end

  def self.create_card(options = {})
    setup_options!(options)
    new_url =  (N::LOCAL + 'firb_card/' + random_id).to_s
    options[:uri] = new_url
    raise(ArgumentError, "Record already exists #{new_url}") if(TaliaCore::ActiveSource.exists?(new_url))
    self.new(options) # Check if it attaches :image_zone and :anastatica
  end
  
  def self.create_card_with_permission_check(options = {})
    card = create_card(options).create_permission_check!
  end

  def setup_options!(options)
    self.class.setup_options!(options)
  end

  def self.setup_options!(options)
    options.to_options!
    options[N::TALIA.hasBibliography.to_s] = options.delete(:bibliography).to_a.collect { |bib| BibliographyItem.find(bib) }
    options
  end

end