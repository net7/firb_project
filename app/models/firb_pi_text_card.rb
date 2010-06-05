class FirbPiTextCard < FirbTextCard
  hobo_model
  include StandardPermissions
    
  singular_property :anastatica, N::DCT.isPartOf, :force_relation => true
  rdf_property :title, N::DCNS.title
  multi_property :image_zones, N::DCT.isFormatOf, :force_relation => true

  rdf_property :parafrasi, N::DCT.description, :type => :text
  multi_property :non_illustrated_memory_depictions, N::TALIA.hasNonIllustratedMemoryDepiction, :force_relation => true, :dependent => :destroy
  
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