class Anastatica < TaliaCore::Source
  hobo_model # Don't put anything above this
  include StandardPermissions
  
  singular_property :title, N::DCNS.title
  declare_attr_type :title, :string
  singular_property :page_position, N::TALIA.position
  declare_attr_type :page_position, :string
  declare_attr_type :name, :string
  singular_property :image_zone, N::DCT.isFormatOf, :type => ImageZone

  autofill_uri :force => true

  def name
    title || uri.local_name
  end

  def name=(value)
    title = value
  end

  def attached_to_books
    return [] if(new_record?)
    attached_query = ActiveRDF::Query.new(TaliaCore::Collection).select(:collection)
    attached_query.where(:collection, N::DCT.hasPart, self).where(:collection, N::RDF.type, N::DCNS.Collection)
    attached_query.execute.collect { |col| TaliaCollection.from_real_source(col) }
  end

  def unattached_books
    collections = TaliaCollection.all
    attached = attached_to_books
    exclude = FiParade.all + FiProcession.all
    exclude.collect! { |c| c.uri }
    collections.reject { |col| attached.include?(col) || exclude.include?(col.uri) }
  end

  def parts
    ActiveRDF::Query.new(TaliaCore::ActiveSource).select(:part).where(:part, N::DCT.isPartOf, self).execute
  end

  # Parts grouped by class
  def parts_by_class
    part_hash = {}
    my_parts = parts
    my_parts.each do |part|
      part_hash[part.class.name] ||= []
      part_hash[part.class.name] << part
    end
    part_hash
  end

  def showable_parts
    @showable_parts ||= Hash[parts_by_class.select do |k,v|
       v.first.class.respond_to? :shown_in_anastatica
    end]
  end

  def showable_zones
    showable_parts.values.flatten.map do |z|
      z.respond_to?(:image_zones) ? z.image_zones.to_a : z.image_zone
    end.flatten
  end
end
