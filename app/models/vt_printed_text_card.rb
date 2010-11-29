class VtPrintedTextCard < TextCard

  hobo_model
  include StandardPermissions
  autofill_uri :force => true

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
  rdf_property :edition, N::TALIA.edition, :type => TaliaCore::ActiveSource

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
  def get_related_topic_descriptions
    triples = []

    # self > type+tabel
    triples.push [self.uri.to_s, N::RDFS.type, self.type.to_s]
    triples.push [self.uri.to_s, N::RDFS.label, self.name.to_s]

    # TextFragment > hasNote > Note, for each note: self > relatedNote > note
    Note.all.each do |n|
      triples.push [self.uri.to_s, N::FIRBSWN.relatedNote, n.uri.to_s]
      triples.push [n.uri.to_s, N::RDFS.type, N::FIRBSWN.Note]
      triples.push [n.uri.to_s, N::RDFS.label, ((n.name.nil?) ? "" : n.name)+": "+((n.content.nil?) ? "" : n.content)]
    end

    triples
  end
  
end