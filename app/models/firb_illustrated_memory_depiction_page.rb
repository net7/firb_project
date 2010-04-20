class FirbIllustratedMemoryDepictionPage < FirbIllustrationPage
  hobo_model # Don't put anything above this
  
  include StandardPermissions
  
  # Short description: brief desc. of the depiction, say "Male person
  # drawing"
  singular_property :short_description, N::TALIA.short_description
  declare_attr_type :short_description, :text

  # TODO: Shared from the superclass
  declare_attr_type :code, :string
  declare_attr_type :collocation, :string
  declare_attr_type :tecnique, :string
  declare_attr_type :measure, :text
  declare_attr_type :position, :string
  declare_attr_type :descriptive_notes, :text
  declare_attr_type :study_notes, :text
  declare_attr_type :description, :text
  declare_attr_type :completed, :boolean
  
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
    real_options['anastatica'] = FirbAnastaticaPage.find(options[:anastatica]) if(options[:anastatica])
    real_options['image_zone'] = FirbImageZone.find(options[:image_zone]) if(options[:image_zone])
    real_options['code'] = options[:code] if(options[:code])
    real_options['collocation'] = options[:collocation] if(options[:collocation])
    real_options['tecnique'] = options[:tecnique] if(options[:tecnique])
    real_options['measure'] = options[:measure] if(options[:measure])
    real_options['position'] = options[:position] if(options[:position])
    real_options['descriptive_notes'] = options[:descriptive_notes] if(options[:descriptive_notes])
    real_options['study_notes'] = options[:study_notes] if(options[:study_notes])
    real_options['description'] = options[:description] if(options[:description])
    real_options['completed'] = options[:completed] if(options[:completed])
    raise(ArgumentError, "Record already exists #{new_url}") if(TaliaCore::ActiveSource.exists?(new_url))
    self.new(real_options)
  end
  
end