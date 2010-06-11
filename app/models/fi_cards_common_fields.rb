module FiCardsCommonFields
  
  module DefinedProperties
    
    def common_properties
      rdf_property :transcription, N::TALIA.transcription, :type => :text
      singular_property :baldini_text, N::TALIA.baldini, :force_relation => true
      singular_property :cini_text, N::TALIA.cini, :force_relation => true
      manual_property :procession
      manual_property :note
      
      validate :validate_procession
      before_validation :save_procession
    end
    
  end
  
  def procession
    @procession ||= fetch_procession
  end
  
  def procession=(value)
    @procession = (value.is_a?(Procession) ? value : Procession.find(value))
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
    self.save! if(self.new_record?)
    FirbNote.replace_notes(value, self)
  end
  
  def validate_procession
    if(@procession && !@procession.valid?)
      @procession.errors.each_full { |msg| errors.add('procession', msg) }
    end
  end
  
  def save_procession
    if(@procession && (@procession != fetch_procession))
      @procession << self 
      @procession.save
    else
      true
    end
  end
  
  def fetch_procession
    Procession.find(:first, :find_through => [N::DCT.hasPart, self])
  end
  
end