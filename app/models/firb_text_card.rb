class FirbTextCard < TaliaCore::Source
  hobo_model # Don't put anything above this
  
  include StandardPermissions
  
  # These are single-value properties, the system will make sure
  # that there is only one value at a time
  singular_property :parafrasi, N::DCT.description
  singular_property :anastatica, N::DCT.isPartOf
  
  fields do
    uri :string
  end
  
  def name
    "text card #{self.id}"
  end

  # Declare methods (getter/setter pairs) that should be used as
  # fields by hobo. The type will be used by the automatic 
  # forms to decide the input type.
  declare_attr_type :parafrasi, :text
  
  # Multi-value stuff:
  # - No direct support through hobo as a field 
  # - you can use the page.namespace:name notation

  # Creates a page initialazing it with a paraphrase and anastatica_page id
  def self.create_card(parafrasi, ana_id, image_zone_list)
    hans = FirbTextCard.new(N::LOCAL + 'FirbTextCard/' + FirbImageElement.random_id)
    hans.parafrasi = parafrasi unless(parafrasi.blank?)
    if (!ana_id.blank?)
      hans.anastatica = FirbAnastaticaPage.find(ana_id)
    end
    image_zone_list.each{ |iz| hans[N::DCT.isFormatOf] << FirbImageZone.find(iz) }

    hans
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
  
  def image_zones
    self[N::DCT.isFormatOf]
  end
  
end