class VtPrintedTextCard < TextCard
  hobo_model
  include StandardPermissions

  include Mixin::Searchable
  include Mixin::Facetable::Vt

  autofill_uri :force => true
  setup_publish_properties

  singular_property :anastatica, N::DCT.isPartOf, :type => TaliaCore::ActiveSource

  rdf_property :title, N::DCNS.title

  # Link a trascrizione diplomatica e trascrizione versione a stampa
  rdf_property :transc_diplomatic, N::TALIA.transcription_diplomatic, :type => TaliaCore::ActiveSource
  rdf_property :transc_handwritten, N::TALIA.transcription_handwritten, :type => TaliaCore::ActiveSource

  # Numero pagina
  rdf_property :page_position, N::TALIA.position
  
  # Collocazione
  rdf_property :collocation, N::TALIA.provenance
  
  # Edizione di riferimento
  multi_property :edition, N::TALIA.edition, :type => TaliaCore::ActiveSource

  # Bibliografia
  multi_property :bibliography_items, N::TALIA.hasBibliography, :type => TaliaCore::ActiveSource
  
  manual_property :notes

  # Lettera a cui appartiene
  manual_property :letter
  before_validation :validate_letter
  after_save :save_letter

  fields do
    uri :string
  end

  def letter
    @letter ||= fetch_letter
  end

  def letter=(value)
    unless value.empty?
      @letter = (value.is_a?(TaliaCollection) ? value : TaliaCollection.find(value)).real_source
      @letter_new = true
      
      old_letter = fetch_letter
      if !old_letter.nil? && old_letter.to_uri != @letter.to_uri
        # FIXME: ? the following line will not work for some reasons
        # the thing is that you can use delete only passing to it an element retrieved from the collection itself...
        #       old_letter.delete self
        old_letter.each do |el|
          if el.uri == self.uri
            old_letter.delete el
            break
          end
        end
        
        old_letter.save
        
        @letter << self
      elsif old_letter.nil?
        @letter << self
      end
    end
  end

  def index_in_letter
    @position_in_letter ||= letter.printed_cards.index self
  end

  def next_card
    letter.printed_cards[index_in_letter.next]
  end

  def previous_card
    index_in_letter < 1 ? nil : letter.printed_cards[index_in_letter.pred]
  end

  def boxview_data
    { :controller => 'boxview/vt_printed_text_cards',
      :title => "Trascrizione critica stampa: #{self.anastatica.page_position}",
      :description => "",
      :res_id => "vt_printed_text_card_#{self.id}",
      :box_type => 'transcription',
      :thumb => nil
    }
  end

  def validate_letter
    if(!letter_valid?)
      @letter.errors.each_full { |msg| errors.add('letter', msg) }
    end
    letter_valid?
  end
  
  def save_letter
    is_new = @letter_new
    @letter_new = false
    is_new ? @letter.save : letter_valid?
  end
  
  def fetch_letter
    # TODO: why this commented ActiveRDF query fails??!?
    #letter = ActiveRDF::Query.new(TaliaCollection).select(:letter).where(:letter, N::DCT.hasPart, self.uri).execute.first
    letter = TaliaCollection.find(:first, :find_through => [N::DCT.hasPart, self.uri]) 
    letter ? letter.real_source : nil
  end
  
  def letter_valid?
    @letter ? @letter.valid? : true
  end
  
  # Produces an array of triples, where a triple is an array subject - predicate - object
  # meant to be used with rdf_builder's prepare_triples
  # TextFragment > hasNote > Note, for each note: self > relatedNote > note
  # TextFragment > VariousRelations > DictionaryItem
  def get_related_topic_descriptions
    triples = []

    # self > type+tabel
    triples.push [self.uri, N::RDF.type, self.type.to_s]
    triples.push [self.uri, N::RDFS.label, self.name.to_s]

    # TextFragment > hasNote > Note, for each note: self > relatedNote > note
    self.notes.each do |n|
      triples.push [self.uri, N::FIRBSWN.relatedNote, n.uri]
      triples.push [n.uri, N::RDF.type, N::FIRBSWN.Note]
      triples.push [n.uri, N::RDFS.label, ((n.name.nil?) ? "" : n.name)+": "+((n.content.nil?) ? "" : n.content)]
    end

    # TextFragment > VariousRelations > DictionaryItem
    DictionaryItem.all.each do |di|
      triples.push [self.uri, N::FIRBSWN.relatedDictionaryItem, di.uri]
      triples.push [di.uri, N::RDF.type, N::FIRBSWN.DictionaryItem]
      triples.push [di.uri, N::RDFS.label, "#{di.name} (#{di.item_type.to_uri.local_name})"]
    end

    triples
  end
  
end
