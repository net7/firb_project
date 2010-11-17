class BgTextCard < TextCard

  hobo_model
  include StandardPermissions
  autofill_uri :force => true

  rdf_property :title, N::DCNS.title

  # Link all'anastatica
  singular_property :anastatica, N::DCT.isPartOf, :type => TaliaCore::ActiveSource

  # Numero carta
  rdf_property :page_position, N::TALIA.position

  # Commento
  rdf_property :comment, N::TALIA.comment, :type => 'string'

  # Bibliografia
  multi_property :bibliography_items, N::TALIA.hasBibliography, :type => TaliaCore::ActiveSource

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
    book = ActiveRDF::Query.new(TaliaCollection).select(:book).where(:book, N::DCT.hasPart, self).execute.first
    book ? book.real_source : nil
  end
  
  def book_valid?
    @book ? @book.valid? : true
  end
    
end