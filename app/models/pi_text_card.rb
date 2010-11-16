class PiTextCard < TextCard
  hobo_model
  include StandardPermissions
  autofill_uri :force => true
    
  singular_property :anastatica, N::DCT.isPartOf, :type => TaliaCore::ActiveSource
  rdf_property :title, N::DCNS.title
  multi_property :image_zones, N::DCT.isFormatOf, :type => TaliaCore::ActiveSource

  rdf_property :parafrasi, N::DCT.description, :type => :text
  multi_property :non_illustrated_memory_depictions, N::TALIA.hasNonIllustratedMemoryDepiction, :type => TaliaCore::ActiveSource, :dependent => :destroy
  
  # TODO: Hacks superclass internal behaviour
  def self.split_attribute_hash(options)
    unless(options[:non_illustrated_memory_depictions].blank?)
      options[:non_illustrated_memory_depictions].collect! do |comp_options|
        if(comp_options.is_a?(TaliaCore::ActiveSource))
          comp_options
        elsif(comp_options[:uri].blank?)
          comp = PiNonIllustratedMdCard.new(comp_options)
          comp.save!
          comp
        else
          PiNonIllustratedMdCard.find(comp_options[:uri])
        end
      end
    end
    super(options)
  end
  
end