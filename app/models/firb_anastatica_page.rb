class FirbAnastaticaPage < TaliaCore::Source
  hobo_model # Don't put anything above this
  include StandardPermissions
  extend RandomId
  
  singular_property :title, N::DCNS.title
  declare_attr_type :title, :string
  singular_property :page_position, N::TALIA.position
  declare_attr_type :page_position, :string
  declare_attr_type :name, :string
  
  def self.create_page(options = {})
    options.to_options!
    new_url =  (N::LOCAL + 'anastatica/' + random_id).to_s
    options[:uri] = new_url
    raise(ArgumentError, "Record already exists #{new_url}") if(TaliaCore::ActiveSource.exists?(new_url))
    self.new(options)
  end
  
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
    return collections if(new_record?)
    attached = attached_to_books
    collections.reject { |col| attached.include?(col) }
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
  
end