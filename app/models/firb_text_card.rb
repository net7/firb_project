class FirbTextCard < TaliaCore::Source

  extend RandomId
  extend RdfProperties
  
  fields do
    uri :string
  end
  
  def name
    title || "#{I18n.t('firb_text_card.model_name')} #{self.id}"
  end
  
  # Creates a page initialazing it with a paraphrase and anastatica_page id
  def self.create_card(options)
    new_url =  (N::LOCAL + 'firb_text_card/' + random_id).to_s
    options[:uri] = new_url
    raise(ArgumentError, "Record already exists #{new_url}") if(TaliaCore::ActiveSource.exists?(new_url))
    self.new(options) # Check if it attaches :image_zone and :anastatica
  end
  
  # TODO: Hacks superclass internal behaviour
  def self.split_attribute_hash(options)
    unless(options[:non_illustrated_memory_depictions].blank?)
      options[:non_illustrated_memory_depictions].collect! do |comp_options|
        if(comp_options.is_a?(TaliaCore::ActiveSource))
          comp_options
        elsif(comp_options[:uri].blank?)
          comp = FirbNonIllustratedMemoryDepictionCard.create_card(comp_options)
          comp.save!
          comp
        else
          FirbNonIllustratedMemoryDepictionCard.find(comp_options[:uri])
        end
      end
    end
    super(options)
  end

  def has_anastatica_page?
    !self.anastatica.blank?
  end

  def notes
    qry = ActiveRDF::Query.new(FirbNote).select(:note).distinct
    qry.where(:note, N::DCT.isPartOf, self)
    qry.execute
  end

  def notes_count
    notes.count
  end
  
  def has_notes?
    !new_record? && (notes.count > 0)
  end
  
end