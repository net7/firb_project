class TextCard < TaliaCore::Source

  extend RandomId
  extend RdfProperties
  include FileAttached

  include Mixin::Publish
  extend Mixin::Publish::PublishProperties

  autofill_uri :force => true

  manual_property :note
  
  fields do
    uri :string
  end  

  def name
    title || "#{I18n.t('text_card.model_name')} #{self.id}"
  end
  
  # Creates a page initialazing it with a paraphrase and anastatica_page id
  def self.create_card(options)
    new_url =  (N::LOCAL + 'text_card/' + random_id).to_s
    options[:uri] = new_url
    self.new(options) # Check if it attaches :image_zone and :anastatica
  end

  def has_anastatica_page?
    !self.anastatica.blank?
  end

  def notes
    qry = ActiveRDF::Query.new(Note).select(:note).distinct
    qry.where(:note, N::DCT.isPartOf, self)
    qry.execute
  end

  def notes_count
    notes.count
  end
  
  def has_notes?
    !new_record? && (notes.count > 0)
  end

  def self.split_attribute_hash(options)
    unless(options[:bibliography_items].blank?)
      options[:bibliography_items].collect! do |bibl|
        if (bibl.is_a?(CustomBibliographyItem))
          bibl
        elsif (bibl.is_a?(BibliographyItem))
          bibl
        elsif (bibl[:uri].blank?)
          new_custom_bibl = CustomBibliographyItem.new(bibl)
          new_custom_bibl.save!
          new_custom_bibl
        elsif (BibliographyItem.exists?(bibl[:uri]))
          # TODO: this shouldnt be needed when we deploy the new bibl-store
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
    super(options)
  end

end