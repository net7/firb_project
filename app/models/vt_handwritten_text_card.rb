class VtHandwrittenTextCard < TextCard

  hobo_model
  include StandardPermissions
  autofill_uri :force => true
  
  rdf_property :anastatica, N::DCT.isPartOf, :type => TaliaCore::ActiveSource
  rdf_property :title, N::DCNS.title

  # Link a trascrizione diplomatica e trascrizione versione a stampa
  rdf_property :transc_diplomatic, N::TALIA.transcription_diplomatic, :type => TaliaCore::ActiveSource
  rdf_property :transc_printed, N::TALIA.transcription_printed, :type => TaliaCore::ActiveSource
  
  # Segnatura
  rdf_property :signature, N::TALIA.signature

  # Misure
  rdf_property :measure, N::TALIA.measure

  # Filigrana
  rdf_property :watermark, N::TALIA.watermark
  
  # Cartulazione
  rdf_property :cartulation, N::TALIA.cartulation

  # Note tecniche
  rdf_property :technical_notes, N::TALIA.techical_notes, :type => 'text'
  
  # Altre note manoscritte
  rdf_property :handwritten_notes, N::TALIA.handwritten_notes, :type => 'text'
  
  # Stato di conservazione
  rdf_property :conservation_status, N::TALIA.conservation_status
  
  # Autografia
  rdf_property :autography, N::TALIA.autography
  
  # Data 
  rdf_property :date, N::DCT.date

  # Bibliografia
  multi_property :bibliography_items, N::TALIA.hasBibliography, :type => TaliaCore::ActiveSource
  
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
    @letter = (value.is_a?(TaliaCollection) ? value : TaliaCollection.find(value)).real_source
    @letter_new = true
    @letter << self
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
    # TODO: why this first ActiveRDF query doesnt work? 
    #letter = ActiveRDF::Query.new(TaliaCollection).select(:letter).where(:letter, N::DCT.hasPart, self).execute.first
    letter = TaliaCollection.find(:first, :find_through => [N::DCT.hasPart, self.uri]) 
    letter ? letter.real_source : nil
  end
  
  def letter_valid?
    @letter ? @letter.valid? : true
  end
    
  # Produces an array of triples, where a triple is an array subject - predicate - object
  # meant to be used with rdf_builder's prepare_triples
  # TextFragment > hasNote > Note, for each note: self > relatedNote > note
  def get_related_topic_descriptions
    triples = []

    # self > type+tabel
    triples.push [self.uri, N::RDF.type, self.type.to_s]
    triples.push [self.uri, N::RDFS.label, self.name.to_s]

    # TextFragment > hasNote > Note, for each note: self > relatedNote > note
    Note.all.each do |n|
      triples.push [self.uri, N::FIRBSWN.relatedNote, n.uri]
      triples.push [n.uri, N::RDF.type, N::FIRBSWN.Note]
      triples.push [n.uri, N::RDFS.label, ((n.name.nil?) ? "" : n.name)+": "+((n.content.nil?) ? "" : n.content)]
    end

    triples
  end

end