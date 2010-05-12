class FirbIllustrationCard < FirbCard

  singular_property  :image_zone, N::DCT.isFormatOf

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

  def inherited_iconclasses
    ActiveRDF::Query.new(IconclassTerm).select(:iconclass).where(:card, N::DCT.isPartOf, self).where(:card, N::DCT.subject, :iconclass).execute
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

  def image_components
    self[N::TALIA.image_component]
  end
  
  def self.replace_iconclass_terms(new_terms, page)
    FirbIllustrationPage.remove_iconclass_terms(page)
    FirbIllustrationPage.add_iconclass_terms(new_terms, page)
    page.save
  end
  
  def self.setup_options!(options)
    options.to_options!
    options[N::DCT.subject.to_s] = options.delete(:iconclass).to_a.collect { |ic| IconclassTerm.find(ic) }
    super(options)
  end

end