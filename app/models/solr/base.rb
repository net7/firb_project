module SOLR
  class Base
    attr_accessor :uri
    attr_reader   :original

    def self.from(original)
      @original = original
      new original.uri
    end

    def initialize(uri)
      self.uri = uri
      @original = original_class.new uri 
    end

    def original_class
      self.class.name.gsub(/SOLR::/, '').constantize
    rescue
      raise Exception, "This solr class does not seem to have a corresponding Talia class."
    end

    def solr_index
      Sunspot.index self
    end

    def solr_index!
      Sunspot.index! self
    end

    def method_missing(method)
      if @original.respond_to? method
        @original.send method unless method.to_s.ends_with? '='
      else
        super
      end
    end
  end
end
