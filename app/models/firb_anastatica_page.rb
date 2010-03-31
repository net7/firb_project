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
    real_options = {}
    real_options[:uri] = new_url
    real_options['dcns:title'] = options[:title] if(options[:title])
    real_options['talia:position'] = options[:page_position] if(options[:page_position])
    raise(ArgumentError, "Record already exists #{new_url}") if(TaliaCore::ActiveSource.exists?(new_url))
    self.new(real_options)
  end
  
  def name
    title || uri.local_name
  end
  
  def name=(value)
    title = value
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