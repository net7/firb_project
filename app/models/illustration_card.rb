class IllustrationCard < BaseCard

  singular_property :image_zone, N::DCT.isFormatOf, :type => TaliaCore::ActiveSource
  multi_property :textual_source, N::TALIA.attachedText, :type => TaliaCore::ActiveSource
  multi_property :iconclass_terms, N::DCT.subject, :type => TaliaCore::ActiveSource
  multi_property :image_components, N::TALIA.image_component, :type => TaliaCore::ActiveSource, :dependent => :destroy

  autofill_uri :force => true

  include Mixin::HasParts

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
  # TODO: Simone 10nov - do we need to check also deleted entries here??
  def self.split_attribute_hash(options)
    unless(options[:bibliography_items].blank?)
      options[:bibliography_items].collect! do |bibl|
        if(bibl.is_a?(CustomBibliographyItem))
          bibl
        elsif (bibl.is_a?(BibliographyItem))
          bibl
        elsif (bibl[:uri].blank?)
          new_custom_bibl = CustomBibliographyItem.new(bibl)
          new_custom_bibl.save!
          new_custom_bibl
        # TODO: this shouldnt be needed when we deploy the new bibl-store
        elsif (BibliographyItem.exists?(bibl[:uri]))
          BibliographyItem.find(bibl[:uri])
        elsif (CustomBibliographyItem.exists?(bibl[:uri]))
          CustomBibliographyItem.find(bibl[:uri])
        end
      end
    end
    unless(options[:modern_bibliography_items].blank?)
      options[:modern_bibliography_items].collect! do |bibl|
        if(bibl.is_a?(CustomBibliographyItem))
          bibl
        elsif (bibl.is_a?(BibliographyItem))
          bibl
        elsif (bibl[:uri].blank?)
          new_custom_bibl = CustomBibliographyItem.new(bibl)
          new_custom_bibl.save!
          new_custom_bibl
        # TODO: this shouldnt be needed when we deploy the new bibl-store
        elsif (BibliographyItem.exists?(bibl[:uri]))
          BibliographyItem.find(bibl[:uri])
        elsif (CustomBibliographyItem.exists?(bibl[:uri]))
          CustomBibliographyItem.find(bibl[:uri])
        end
      end
    end
    unless(options[:edition].blank?)
      options[:edition].collect! do |bibl|
        if(bibl.is_a?(CustomBibliographyItem))
          bibl
        elsif (bibl.is_a?(BibliographyItem))
          bibl
        elsif (bibl[:uri].blank?)
          new_custom_bibl = CustomBibliographyItem.new(bibl)
          new_custom_bibl.save!
          new_custom_bibl
        # TODO: this shouldnt be needed when we deploy the new bibl-store
        elsif (BibliographyItem.exists?(bibl[:uri]))
          BibliographyItem.find(bibl[:uri])
        elsif (CustomBibliographyItem.exists?(bibl[:uri]))
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

  # TODO this could be the wrong relation, make sure.
  def parts_query
    ActiveRDF::Query.new(TaliaCore::ActiveSource).select(:part).where(:part, N::TALIA.parent_card, self)
  end

  def iconclasses(sort=true, all=true)
    iconclasses = self.iconclass_terms.map {|i| i}

    self.children.each do |child|
      child.iconclass_terms.each do |iconclass|
        iconclasses << iconclass
      end
    end if all

    iconclasses.sort! do |iconclass1, iconclass2|
      iconclass1.label <=> iconclass2.label
    end if sort

    iconclasses.uniq
  end

  def self.find_anastaticas_by_iconclass(iconclass)
    qry = ActiveRDF::Query.new(Anastatica).select(:ana).distinct
    qry.where(:ill, N::DCT.subject, iconclass)
    qry.where(:ill, N::DCT.isPartOf, :ana)
    qry.execute
  end
  
  def self.find_by_iconclass(iconclass)
    qry = ActiveRDF::Query.new(IllustrationCard).select(:ill).distinct
    qry.where(:ill, N::DCT.subject, iconclass)
    qry.execute
  end
  



  def previous_card
    anastatica = self.anastatica
    return nil unless anastatica.present?
    collection = anastatica.collections.first
    return nil if collection.nil?
    begin
      anastatica = collection.prev(anastatica)
      return nil if anastatica.nil?
      prev_card = anastatica.inverse[N::DCT.isPartOf].first unless anastatica.nil?
    end while prev_card.class != self.class and prev_card.present? and !prev_card.is_public?
    return prev_card unless prev_card.class != self.class
  end

  def next_card
    anastatica = self.anastatica
    return nil unless anastatica.present?
    collection = anastatica.collections.first
    return nil if collection.nil?
    begin
      anastatica = collection.next(anastatica)
      return nil if anastatica.nil?
      next_card = anastatica.inverse[N::DCT.isPartOf].first unless anastatica.nil?
    end while next_card.class != self.class and next_card.present? and !next_card.is_public?
    return next_card unless next_card.class != self.class
  end




end
