class FirbIllustrationPage < TaliaCore::Source

  singular_property :name, N::TALIA.name

  attr_accessor :image
  
  extend RandomId

  # Anastatica page it links to
  singular_property :anastatica, N::DCT.isPartOf

  # Image zone this illustration is in
  singular_property :image_zone, N::DCT.isFormatOf

  # Code: internal identifier used by the owner of the original source
  # to archive it
  singular_property :code, N::TALIA.identifier

  # Collocation: phisical place where the original manuscript
  # (or, in general, the original source) can be found or is conserved
  singular_property :collocation, N::TALIA.provenance

  # Tecnique: used to describe the way the image has been drawn
  # say: "oil on paper" or "pencil on wood"
  singular_property :tecnique, N::TALIA.tecnique

  # Measure: describes the phisical dimensions of the depiction
  # usually in centimeters
  singular_property :measure, N::TALIA.measure
  
  # Position: describes the position of the depiction inside the
  # "big picture", say "upper left corner" or "bottom part"
  singular_property :position, N::DCT.position
  
  # Descriptive notes: some notes which describes the depiction, meant to
  # be a kinf of appendix of the description field
  singular_property :descriptive_notes, N::TALIA.descriptive_notes

  # Study notes: some informations about the illustration, say "four depictions
  # are positioned clockwise in the four corners of a room with gray floor
  # and green walls. The fifth depiction is positioned between the door and
  # and the fourth depiction"
  singular_property :study_notes, N::TALIA.study_notes

  # Description: long description of the depiction, say "Male person
  # dressed in green and red, with a white hat and long brown hair, is
  # using his left hand to draw while the right one is keeping a cross on
  # his chest"
  singular_property :description, N::TALIA.description

  # Completed: true if the illustration is fully completed or false if
  # say some colors are not on their place or some parts are only sketched
  singular_property :completed, N::TALIA.completed

  fields do
    uri :string
  end

  def iconclass_terms
    qry = ActiveRDF::Query.new(IconclassTerm).select(:it).distinct
    qry.where(self, N::DCT.subject, :it)
    qry.execute
  end

  def iconclass_terms_count
    iconclass_terms.count
  end
  
  def has_iconclass_terms?
    iconclass_terms.count > 0
  end
  
  # Remove action, no special linked items to remove
  def remove
    self.remove_iconclass_terms
    self.destroy
  end

  def has_anastatica_page?
    !self.anastatica.blank?
  end

  def self.remove_iconclass_terms(page)
    page.iconclass_terms.each do |t|
      page[N::DCT.subject].remove(t)
    end
  end

  def self.add_iconclass_terms(terms, page)
    terms.each do |key, value|
      iconclass_term = IconclassTerm.find_by_term(value)
      if (!iconclass_term.nil?)
        page.dct::subject << iconclass_term
      end
    end
  end
  
  def self.replace_iconclass_terms(new_terms, page)
    FirbIllustrationPage.remove_iconclass_terms(page)
    FirbIllustrationPage.add_iconclass_terms(new_terms, page)
    page.save
  end

end