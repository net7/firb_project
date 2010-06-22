class BgTextCard < TextCard

  hobo_model
  include StandardPermissions

  rdf_property :title, N::DCNS.title

  # Link all'anastatica
  singular_property :anastatica, N::DCT.isPartOf, :force_relation => true

  # Numero carta
  rdf_property :page_position, N::TALIA.position

  # Collocazione
  rdf_property :collocation, N::TALIA.provenance

  # Segnatura
  rdf_property :signature, N::TALIA.signature

  # Autore
  rdf_property :author, N::DCT.creator

  # Commento
  rdf_property :comment, N::TALIA.comment, :type => 'text'

  # Libro a cui appartiene
  manual_property :book
  before_validation :validate_book
  after_save :save_book

  fields do
    uri :string
  end

  def book
    @book ||= fetch_book
  end
  
  def book=(value)
    @book = (value.is_a?(TaliaCollection) ? value : TaliaCollection.find(value)).real_source
    @book_new = true
    @book << self
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
    book ? book.real_source : nil
  end
  
  def book_valid?
    @book ? @book.valid? : true
  end
    
end