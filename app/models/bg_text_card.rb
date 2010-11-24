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
    
end
