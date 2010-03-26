class FirbTextPage < TaliaCore::Source
  hobo_model # Don't put anything above this
  
  include StandardPermissions
  
  # These are single-value properties, the system will make sure
  # that there is only one value at a time
  singular_property :title, N::DCNS.title
  singular_property :parafrasi, N::DCT.description
  singular_property :anastatica, N::DCT.isPartOf
  
  fields do
    uri :string
  end

  # Declare methods (getter/setter pairs) that should be used as
  # fields by hobo. The type will be used by the automatic 
  # forms to decide the input type.
  declare_attr_type :title, :string
  declare_attr_type :parafrasi, :text
  
  # Multi-value stuff:
  # - No direct support through hobo as a field 
  # - you can use the page.namespace:name notation

  # Creates a page initialazing it with a paraphrase and anastatica_page id
  def self.create_page(parafrasi, ana_id)
    p = FirbTextPage.new(N::LOCAL + 'firbtextpage/' + FirbImageElement.random_id)
    p.parafrasi = parafrasi
    if (!ana_id.blank?)
      anastatica = FirbAnastaticaPage.find(ana_id)
      p[N::DCT.isPartOf] << anastatica
    end
    p
  end

  # Removes a text_page
  def remove
    self.destroy
  end

  def has_anastatica_page?
    !anastatica_page.blank?
  end
  
  def self.anastatiche_select
    FirbAnastaticaPage.all.collect{|a| ["#{a.title}: #{a.id}", a.id]}
  end
  
  def anastatica_page
    qry = ActiveRDF::Query.new(FirbAnastaticaPage).select(:p).distinct
    qry.where(self, N::DCT.isPartOf, :p)
    qry.execute.first
  end
  
end