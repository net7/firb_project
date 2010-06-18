class FiTextCard < TextCard

  hobo_model
  include StandardPermissions

  rdf_property :title, N::DCNS.title

  # Edizione di riferimento
  rdf_property :edition, N::TALIA.edition, :force_relation => true

  # Numero pagina
  rdf_property :page_position, N::TALIA.position

  fields do
    uri :string
  end
  
  # TODO: Hacks superclass internal behaviour
  def self.split_attribute_hash(options)
    unless(options[:non_illustrated_memory_depictions].blank?)
      options[:non_illustrated_memory_depictions].collect! do |comp_options|
        if(comp_options.is_a?(TaliaCore::ActiveSource))
          comp_options
        elsif(comp_options[:uri].blank?)
          comp = FirbNonIllustratedMemoryDepictionCard.new(comp_options)
          comp.save!
          comp
        else
          FirbNonIllustratedMemoryDepictionCard.find(comp_options[:uri])
        end
      end
    end
    super(options)
  end
    
end