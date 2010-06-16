module FiCardsCommonFields
  
  module DefinedProperties
    
    def common_properties
      rdf_property :transcription, N::TALIA.transcription, :type => :text
      singular_property :baldini_text, N::TALIA.baldini, :force_relation => true
      singular_property :cini_text, N::TALIA.cini, :force_relation => true
      manual_property :procession
      manual_property :note
      
      before_validation :validate_procession
      after_save :save_procession
    end
    
  end
  
  def procession
    @procession ||= fetch_procession
  end
  
  def procession=(value)
    @procession = (value.is_a?(Procession) ? value : Procession.find(value))
    @procession_new = true
    @procession << self
  end
  
  def note
    qry = ActiveRDF::Query.new(Note).select(:note).distinct
    qry.where(:note, N::DCT.isPartOf, self)
    qry.execute
  end
  
  def notes
    note
  end
  
  def note=(value)
    if(self.new_record?)
      return unless(self.save)
    end
    Note.replace_notes(value, self)
  end
  
  def validate_procession
    if(!procession_valid?)
      @procession.errors.each_full { |msg| errors.add('procession', msg) }
    end
    procession_valid?
  end
  
  def save_procession
    is_new = @procession_new
    @procession_new = false
    is_new ? @procession.save : procession_valid?
  end
  
  def fetch_procession
    Procession.find(:first, :find_through => [N::DCT.hasPart, self])
  end
  
  def procession_valid?
    @procession ? @procession.valid? : true
  end
  
end