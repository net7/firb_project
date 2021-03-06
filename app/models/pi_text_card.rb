class PiTextCard < TextCard
  hobo_model
  include StandardPermissions
  extend Mixin::Showable
  include Mixin::Searchable
  include Mixin::Facetable::Pi

  showable_in Anastatica
  setup_publish_properties

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

  # Produces an array of triples, where a triple is an array subject - predicate - object
  # meant to be used with rdf_builder's prepare_triples
  # 1 TextFragment > hasNote > Note, for each note: self > relatedNote > note
  # 2 TextFragment > keywordForImageZone > ImageZone, for each imgz: self > relatedImageZone > imgz
  # 3 TextFragment > hasMemoryDepiction > MemoryDepiction, for each md (ill+not ill): self > relatedMemoryDepiction > md
  # 4 TextFragment > VariousRelations > DictionaryItem
  def get_related_topic_descriptions
    triples = []

    # self > type+tabel
    triples.push [self.uri, N::RDF.type, self.type.to_s]
    triples.push [self.uri, N::RDFS.label, self.name.to_s]

    # 1 TextFragment > hasNote > Note, for each note: self > relatedNote > note
    self.notes.each do |n|
      triples.push [self.uri, N::FIRBSWN.relatedNote, n.uri]
      triples.push [n.uri, N::RDF.type, N::FIRBSWN.Note]
      triples.push [n.uri, N::RDFS.label, ((n.name.nil?) ? "" : n.name)+": "+((n.content.nil?) ? "" : n.content)]
    end

    # 2 TextFragment > keywordForImageZone > ImageZone, for each imgz: self > relatedImageZone > imgz
    ImageZone.get_all_zones_array.each do |name, uri|
      triples.push [self.uri, N::FIRBSWN.relatedImageZone, N::URI.new(uri)]
      triples.push [uri, N::RDF.type, N::FIRBSWN.ImageZone]
      triples.push [uri, N::RDFS.label, name]
    end

    # 3 TextFragment > hasMemoryDepiction > MemoryDepiction, for each md (ill+not ill): self > relatedMemoryDepiction > md
    self.non_illustrated_memory_depictions.each do |md|
      triples.push [self.uri, N::FIRBSWN.relatedMemoryDepiction, md.uri]
      triples.push [md.uri, N::RDF.type, N::FIRBSWN.NonIllustratedMemoryDepiction]
      triples.push [md.uri, N::RDFS.label, "("+md.depiction_type+") " + md.short_description]
    end

    PiIllustratedMdCard.find(:all, :find_through => [N::TALIA.attachedText, self.uri]).each do |md|
      triples.push [self.uri, N::FIRBSWN.relatedMemoryDepiction, md.uri]
      triples.push [md.uri, N::RDF.type, N::FIRBSWN.IllustratedMemoryDepiction]
      triples.push [md.uri, N::RDFS.label, md.short_description]
    end 

    # 4 TextFragment > VariousRelations > DictionaryItem
    DictionaryItem.all.each do |di|
      triples.push [self.uri, N::FIRBSWN.relatedDictionaryItem, di.uri]
      triples.push [di.uri, N::RDF.type, N::FIRBSWN.DictionaryItem]
      triples.push [di.uri, N::RDFS.label, "#{di.name} (#{di.item_type.to_uri.local_name})"]
    end
        
    triples
  end

  def boxview_data
    desc = self.parafrasi.nil? ? "" : "#{self.parafrasi.slice(0, 80)}.."
    { :controller => 'boxview/pi_scheda_testo', 
      :title => "Scheda testo: #{self.anastatica.page_position}", 
      :description => desc,
      :res_id => "pi_text_card_#{self.id}", 
      :box_type => 'transcription',
      :thumb => nil
    }
  end
end
