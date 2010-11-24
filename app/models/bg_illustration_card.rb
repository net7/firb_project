# -*- coding: utf-8 -*-
# Represents a 
class BgIllustrationCard < IllustrationCard

  include StandardPermissions

  autofill_uri :force => true

  # Fonti dell'immagine (in) ed usi successivi (out)
  multi_property :related_source_in, N::TALIA.related_source_in, :type => TaliaCore::ActiveSource
  multi_property :related_source_out, N::TALIA.related_source_out, :type => TaliaCore::ActiveSource

  # Segnatura
  rdf_property :signature, N::TALIA.signature

  # Note descrittive / tecniche
  rdf_property :technical_notes, N::TALIA.techical_notes, :type => 'text'
    
  # Edizione di riferimento
  rdf_property :edition, N::TALIA.edition, :type => TaliaCore::ActiveSource

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
  def get_related_topic_descriptions
    triples = []
    # For each image_zone add:
    # self - 'related_image' - image_zone
    # image_zone - 'type' - ImageZone
    # image_zone - 'label' - image_zone.name
    ImageZone.get_all_zones_array.collect do |name, uri|
      triples.push [self.uri.to_s, 'http://talia.discovery-project.eu/wiki/TaliaInternal#related_image', uri]
      triples.push [uri, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type', 'ImageZone']
      triples.push [uri, 'http://talia.discovery-project.eu/wiki/TaliaInternal#label', name]
    end
    # 'related_image' - 'label' - '..'
    triples.push ['http://talia.discovery-project.eu/wiki/TaliaInternal#related_image', 'http://talia.discovery-project.eu/wiki/TaliaInternal#label', 'Zone di immagine associabili']

    # self - 'type' - self.type
    # self - 'label' - self.name
    triples.push [self.uri.to_s, 'http://talia.discovery-project.eu/wiki/TaliaInternal#type', self.type.to_s]
    triples.push [self.uri.to_s, 'http://talia.discovery-project.eu/wiki/TaliaInternal#label', self.name.to_s]

    # 'is_depicted_in' - 'range' - ImageZone
    # 'is_depicted_in' - 'label' - '..'
    triples.push ['http://talia.discovery-project.eu/wiki/TaliaInternal#is_depicted_in', 'http://talia.discovery-project.eu/wiki/TaliaInternal#range', 'ImageZone']
    triples.push ['http://talia.discovery-project.eu/wiki/TaliaInternal#is_depicted_in', 'http://talia.discovery-project.eu/wiki/TaliaInternal#label', 'è rappresentata in']
    
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
