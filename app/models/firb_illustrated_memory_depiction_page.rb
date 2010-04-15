class FirbIllustratedMemoryDepictionPage < FirbIllustrationPage
  
  # Short description: brief desc. of the depiction, say "Male person
  # drawing"
  singular_property :short_description, N::TALIA.short_description
  declare_attr_type :short_description, :text

  # Still missing:
  # textual source: link to a text page
  # links to component depictions pages

  
  fields do
    uri :string
  end
  
  def self.create_page(options = {})
    options.to_options!
    new_url =  (N::LOCAL + 'firbillustratedmemorydepiction/' + random_id).to_s
    real_options = {}
    real_options[:uri] = new_url
    #real_options['anastatica'] = options[:title] if(options[:title])
    #real_options['talia:position'] = options[:page_position] if(options[:page_position])
    raise(ArgumentError, "Record already exists #{new_url}") if(TaliaCore::ActiveSource.exists?(new_url))
    self.new(real_options)
  end
  
  
end