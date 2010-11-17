module FiCardsCommonFields
  
  module DefinedProperties
    
    def common_properties
      rdf_property :transcription, N::TALIA.transcription, :type => :text
      singular_property :baldini_text, N::TALIA.baldini, :type => TaliaCore::ActiveSource
      singular_property :cini_text, N::TALIA.cini, :type => TaliaCore::ActiveSource
      manual_property :procession
      manual_property :note
      
      before_validation :validate_procession
      after_save :save_procession
    end
    
  end

  # Manual property procession getter and setter
  def procession
    @procession ||= fetch_procession
  end
  
  def procession=(value)
    @procession = (value.is_a?(FiProcession) ? value : FiProcession.find(value))
    @procession_new = true
    remove_from_all_processions(self)
    @procession << self
  end

  # If there's errors validating the procession, add these errors to this
  # object's errors and return false
  def validate_procession
    if(!procession_valid?)
      @procession.errors.each_full { |msg| errors.add('procession', msg) }
    end
    procession_valid?
  end
  
  def remove_from_all_processions(item)
    FiProcession.all.each do |p|
      if (p.include?(item))
        p.delete(item)
        p.save!
      end
    end
  end
  
  def save_procession
    is_new = @procession_new
    @procession_new = false
    is_new ? @procession.save : procession_valid?
  end
  
  def fetch_procession
    ActiveRDF::Query.new(FiProcession).select(:procession).where(:procession, N::DCT.hasPart, self).execute.first
  end

  def procession_valid?
    @procession ? @procession.valid? : true
  end

  # Manual property Note getter and setter
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

  def has_notes?
    !new_record? && (notes.count > 0)
  end
  
end