module FiCardsCommonFields
  
  module DefinedProperties
    
    def common_properties
      rdf_property :transcription, N::TALIA.transcription, :type => :text
      rdf_property :baldini_text, N::TALIA.baldini, :type => :text
      rdf_property :cini_text, N::TALIA.cini, :type => :text
      manual_property :collection
      manual_property :parade
    end
  end
  
  def collection
    TaliaCore::Collection.find(:first, :find_through => [N::DCT.hasPart, self])
  end
  
  def collection=(value)
    value = value.is_a?(TaliaCore::Collection) ? value : TaliaCore::Collection.find(value)
    value << self unless(value.include?(self))
    value.save!
  end
  
  def parade
    Parade.find(:first, :find_through => [N::DCT.hasPart, self])
  end
  
  def parade=(value)
    value = value.is_a?(Parade) ? value : Parade.find(value)
    value << self unless(value.include?(self))
    value.save!
  end
end