class FirbPiTextCard < FirbTextCard
  hobo_model
  include StandardPermissions
    
  singular_property :anastatica, N::DCT.isPartOf, :force_relation => true
  rdf_property :title, N::DCNS.title
  multi_property :image_zones, N::DCT.isFormatOf, :force_relation => true

  rdf_property :parafrasi, N::DCT.description, :type => :text
  multi_property :non_illustrated_memory_depictions, N::TALIA.hasNonIllustratedMemoryDepiction, :force_relation => true, :dependent => :destroy
  
  def self.create_card(options)
    new_url =  (N::LOCAL + 'firb_pi_text_card/' + random_id).to_s
    options[:uri] = new_url
    raise(ArgumentError, "Record already exists #{new_url}") if(TaliaCore::ActiveSource.exists?(new_url))
    self.new(options) # Check if it attaches :image_zone and :anastatica
  end
  
  # TODO: Hacks superclass internal behaviour
  def self.split_attribute_hash(options)
    unless(options[:non_illustrated_memory_depictions].blank?)
      options[:non_illustrated_memory_depictions].collect! do |comp_options|
        if(comp_options.is_a?(TaliaCore::ActiveSource))
          comp_options
        elsif(comp_options[:uri].blank?)
          comp = FirbNonIllustratedMemoryDepictionCard.create_card(comp_options)
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