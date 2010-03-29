# Methods for "fake" source classes that let Hobo play (somewhat) 
# together with the classes from TaliaCore::*
module FakeSource  
  
  # Class methods for fake sources
  module ClassMethods
    
    def real_class
      @real_class ||= TaliaCore::Source
    end
    
    def has_real_class(klass)
      @real_class = klass
    end
    
    def find(*args)
      result = real_class.find(*args)
      if(result.is_a?(Array))
        result.collect { |s| from_real_source(s) }
      else
        from_real_source(result)
      end
    end
    
    def count(*args)
      real_class.count(*args)
    end
    
    def new(*args)
      new_thing = super(*args)
      new_thing[:type] = real_class.name
      new_thing
    end
    
    private

    def from_real_source(real_source)
      result = self.send(:instantiate, real_source.attributes)
      result.real_source = real_source
      result
    end
    
  end
  
  attr_writer :real_source
  
  def real_class
    self.class.real_class 
  end
  
  def name
    real_source.respond_to?(:label) ? real_source.label : to_uri.to_name_s
  end
  
  def short_type
    self.type ? self.type.gsub('TaliaCore::', '') : 'ActiveSource'
  end
  
  def to_uri
    self.uri.to_uri
  end

  def real_source
    @real_source ||= TaliaCore::ActiveSource.find(self.id, :prefetch_relations => true)
  end
  
end