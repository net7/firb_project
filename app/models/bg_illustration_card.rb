class BgIllustrationCard < IllustrationCard

  include StandardPermissions

  extend Mixin::Showable
  showable_in Anastatica

  autofill_uri :force => true

  # Fonti dell'immagine (in) ed usi successivi (out)
  multi_property :related_source_in, N::TALIA.related_source_in, :type => TaliaCore::ActiveSource
  multi_property :related_source_out, N::TALIA.related_source_out, :type => TaliaCore::ActiveSource

  # Segnatura
  rdf_property :signature, N::TALIA.signature

  # Note descrittive / tecniche
  rdf_property :technical_notes, N::TALIA.techical_notes, :type => 'text'
    
  # Edizione di riferimento
  multi_property :edition, N::TALIA.edition, :type => TaliaCore::ActiveSource

  # Motto, lingua e traduzione
  rdf_property :motto, N::TALIA.motto, :type => 'text'
  rdf_property :motto_language, N::TALIA.motto_language, :type => 'string'
  rdf_property :motto_translation, N::TALIA.motto_translation, :type => 'text'

  # Possessore dell'impresa
  rdf_property :owner, N::TALIA.owner, :type => 'string'

  # Significati originale e contestuale
  rdf_property :original_meaning, N::TALIA.original_meaning, :type => 'text'
  rdf_property :contextual_meaning, N::TALIA.contextual_meaning, :type => 'string'

  # Note relative al copyright
  rdf_property :copyright_notes, N::TALIA.copyright_notes, :type => 'string'
    
  # Libro a cui appartiene
  manual_property :book
  before_validation :validate_book
  after_save :save_book

  fields do
    uri :string
  end

  # Produces an array of triples, where a triple is an array subject - predicate - object
  # meant to be used with rdf_builder's prepare_triples
  # TextFragment > keywordForImageZone > ImageZone, for each imgz: self > relatedImageZone > imgz
  def get_related_topic_descriptions
    triples = []

    # self > type+tabel
    triples.push [self.uri, N::RDF.type, self.type.to_s]
    triples.push [self.uri, N::RDFS.label, self.name.to_s]

    # TextFragment > keywordForImageZone > ImageZone, for each imgz: self > relatedImageZone > imgz
    ImageZone.get_all_zones_array.each do |name, uri|
      triples.push [self.uri, N::FIRBSWN.relatedImageZone, N::URI.new(uri)]
      triples.push [uri, N::RDF.type, N::FIRBSWN.ImageZone]
      triples.push [uri, N::RDFS.label, name]
    end
    
    triples
  end

  def book
    @book ||= fetch_book
  end
  
  def book=(value)
    old_book = book
    @book = (value.is_a?(TaliaCollection) ? value : TaliaCollection.find(value)).real_source
    @book_new = true

    if !old_book.nil? && old_book.to_uri != @book.to_uri
      old_book.each do |el|
        if el.uri == self.uri
          old_book.delete el
          break
        end
      end

      old_book.save
      @book << self
    elsif old_book.nil?
      @book << self
    end
  end

  def iconclasses(sort=true)
    super(sort, false)
  end

  def anastatica_sources_in(collection_uri)
    TaliaCore::Collection.find(collection_uri).to_a.compact & related_source_in.to_a.map {|c| c.anastatica unless c.nil?}.compact
  end

  def anastatica_sources_out(collection_uri)
    TaliaCore::Collection.find(collection_uri).to_a.compact & related_source_out.to_a.map {|c| c.anastatica unless c.nil?}.compact
  end

  def validate_book
    if(!book_valid?)
      @book.errors.each_full { |msg| errors.add('book', msg) }
    end
    book_valid?
  end

  def save_book
    is_new = @book_new
    @book_new = false
    is_new ? @book.save : book_valid?
  end

  def fetch_book
    book = TaliaCollection.find(:first, :find_through => [N::DCT.hasPart, self.uri])
    # we need to re-find it because it would be read-only otherwise (!?)
    book ? TaliaCore::Collection.find(book.real_source.uri) : nil
  end

  def book_valid?
    @book ? @book.valid? : true
  end



  # @collection is a TaliaCore::Collection
  # this returns a list of Owners, a field of this model
  def self.owners_for(collection)
    qry = ActiveRDF::Query.new().select(:o).distinct   
    qry.where(:x, N::TALIA.owner, :o)
    qry.execute.sort
  end


  # returns a list of anastatica whose related BgIllustrationCard has the #owner == owner
  def self.menu_items_for(owner)
    qry = ActiveRDF::Query.new(Anastatica).select(:x).distinct
    qry.where(:ill, N::DCT.isPartOf, :x)
    qry.where(:ill, N::TALIA.owner, :o)
    qry.regexp(:o, owner.gsub(/'/,"\\\\'") )
    result = qry.execute
# at the moment bg_illustration_cards have no is_public method
#    result.delete_if {|el| !el.is_public?}
  end


  def boxview_data
    { :controller => 'boxview/bg_illustration_cards', 
      :title => "Scheda illustrazione: #{anastatica.page_position}",
      :description => self.description,
      :res_id => "bg_illustration_card_#{self.id}", 
      :box_type => 'image',
      :thumb => nil
    }
  end
end
