class TextCard < TaliaCore::Source

  extend RandomId
  extend RdfProperties
  include FileAttached

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
    raise(ArgumentError, "Record already exists #{new_url}") if(TaliaCore::ActiveSource.exists?(new_url))
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
    
end