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

  def self.create_page(parafrasi, anastatica)
    p = FirbTextPage.new(N::LOCAL + 'firbtextpage/' + FirbImageElement.random_id)
    txt.parafrasi = parafrasi
    if (!anastatica.blank?)
      self[N::DCT.isPartOf] << anastatica
      zone
    end
    txt
  end

  def has_anastatica_page?
    anastatica_page.blank?
  end
  
  def self.foo_anastatiche
    FirbAnastaticaPage.all.collect{|a| ["#{a.title}: #{a.id}", a.id]}
  end
  
  def anastatica_page
    qry = ActiveRDF::Query.new(FirbAnastaticaPage).select(:p).distinct
    qry.where(self, N::DCT.isPartOf, :p)
    qry.execute.first
  end
  
end