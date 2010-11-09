class IllustrationCard < BaseCard

  singular_property :image_zone, N::DCT.isFormatOf, :type => TaliaCore::ActiveSource
  singular_property :textual_source, N::TALIA.attachedText, :type => TaliaCore::ActiveSource
  multi_property :iconclass_terms, N::DCT.subject, :type => TaliaCore::ActiveSource
  multi_property :image_components, N::TALIA.image_component, :type => TaliaCore::ActiveSource, :dependent => :destroy

  autofill_uri :force => true

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
    IllustrationCard.remove_iconclass_terms(page)
    IllustrationCard.add_iconclass_terms(new_terms, page)
    page.save
  end

  # TODO: Hacks superclass internal behaviour
  def self.split_attribute_hash(options)
    unless(options[:bibliography_items].blank?)
      options[:bibliography_items].collect! do |bibl|
        if(bibl.is_a?(CustomBibliographyItem))
          bibl
        elsif(bibl.is_a?(BibliographyItem))
          bibl
        elsif(bibl[:uri].blank?)
          new_custom_bibl = CustomBibliographyItem.new(bibl)
          new_custom_bibl.save!
          new_custom_bibl
        else
          CustomBibliographyItem.find(bibl[:uri])
        end
      end
    end
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