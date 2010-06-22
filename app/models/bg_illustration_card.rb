# Represents a 
class BgIllustrationCard < IllustrationCard

  include StandardPermissions

  autofill_uri :force => true

  # Fonti dell'immagine (in) ed usi successivi (out)
  rdf_property :related_source_in, N::TALIA.related_source, :force_relation => true
  rdf_property :related_source_out, N::TALIA.related_source, :force_relation => true

  # Segnatura
  rdf_property :signature, N::TALIA.signature

  # Note descrittive / tecniche
  rdf_property :technical_notes, N::TALIA.techical_notes, :type => 'text'
    
  # Edizione di riferimento
  rdf_property :edition, N::TALIA.edition, :force_relation => true

  # Motto, lingua e traduzione
  rdf_property :motto, N::TALIA.motto, :type => 'text'
  rdf_property :motto_language, N::TALIA.motto_language, :type => 'string'
  rdf_property :motto_translation, N::TALIA.motto_translation, :type => 'text'

  # Possessore dell'impresa
  rdf_property :owner, N::TALIA.owner, :type => 'string'

  # Significati originale e contestuale
  rdf_property :original_meaning, N::TALIA.original_meaning, :type => 'text'
  rdf_property :contextual_meaning, N::TALIA.contextual_meaning, :type => 'text'

  # Note relative al copyright
  rdf_property :copyright_notes, N::TALIA.copyright_notes, :type => 'text'
    
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
    return if value.blank?
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