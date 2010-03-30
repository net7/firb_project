class FirbTextPage < TaliaCore::Source
  hobo_model # Don't put anything above this
  
  include StandardPermissions
  
  # These are single-value properties, the system will make sure
  # that there is only one value at a time
  singular_property :parafrasi, N::DCT.description
  singular_property :anastatica, N::DCT.isPartOf
  singular_property :image_zone, N::DCT.isFormatOf
  
  fields do
    uri :string
  end

  # Declare methods (getter/setter pairs) that should be used as
  # fields by hobo. The type will be used by the automatic 
  # forms to decide the input type.
  declare_attr_type :parafrasi, :text
  
  # Multi-value stuff:
  # - No direct support through hobo as a field 
  # - you can use the page.namespace:name notation

  # Creates a page initialazing it with a paraphrase and anastatica_page id
  def self.create_page(parafrasi, ana_id, image_zone_id)
    p = FirbTextPage.new(N::LOCAL + 'firbtextpage/' + FirbImageElement.random_id)
    p.parafrasi = parafrasi
    if (!ana_id.blank?)
      p.anastatica = FirbAnastaticaPage.find(ana_id)
    end
    if (!image_zone_id.blank?)
      p.image_zone = FirbImageZone.find(image_zone_id)
    end
    p
  end

  # Removes a text_page
  def remove
    self.destroy
    # TODO: add notes deletion as well .. 
  end

  def has_anastatica_page?
    !self.anastatica.blank?
  end

  def notes
    qry = ActiveRDF::Query.new(FirbNote).select(:note).distinct
    qry.where(:note, N::DCT.isPartOf, self)
    qry.execute
  end
  
end