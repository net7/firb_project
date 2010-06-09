module FiCardsCommonFields
  
  module DefinedProperties
    
    def common_properties
      rdf_property :transcription, N::TALIA.transcription, :type => :text
      singular_property :baldini_text, N::TALIA.baldini, :force_relation => true
      singular_property :cini_text, N::TALIA.cini, :force_relation => true
      manual_property :parade
      manual_property :note
    end
    
  end
  
  def parade
    Parade.find(:first, :find_through => [N::DCT.hasPart, self])
  end
  
  def parade=(value)
    value = value.is_a?(Parade) ? value : Parade.find(value)
    value << self unless(value.include?(self))
    value.save!
  end
  
  def note
    qry = ActiveRDF::Query.new(FirbNote).select(:note).distinct
    qry.where(:note, N::DCT.isPartOf, self)
    qry.execute
  end
  
  def notes
    note
  end
  
  def note=(value)
    FirbNote.replace_notes(value, self)
  end
  
end