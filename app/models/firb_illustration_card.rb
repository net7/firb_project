class FirbIllustrationCard < BaseCard

  singular_property :image_zone, N::DCT.isFormatOf, :force_relation => true
  singular_property :textual_source, N::TALIA.attachedText, :force_relation => true
  multi_property :iconclass_terms, N::DCT.subject, :force_relation => true
  multi_property :image_components, N::TALIA.image_component, :force_relation => true, :dependent => :destroy

  autofill_uri :force => true

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
      iconclass_term = IconclassTerm.find(value)
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

  # TODO: Hacks superclass internal behaviour
  def self.split_attribute_hash(options)
    unless(options[:image_components].blank?)
      options[:image_components].collect! do |comp_options|
        if(comp_options.is_a?(ImageComponent))
          comp_options
        elsif(comp_options[:uri].blank?)
          comp = ImageComponent.new(comp_options)
          comp.save!
          comp
        else
          ImageComponent.find(comp_options[:uri])
        end
      end
    end
    super(options)
  end

end