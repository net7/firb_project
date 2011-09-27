module SOLR
  class Base
    include ActionController::UrlWriter
    attr_accessor :uri

    def self.solr_setup(&block)
      Sunspot.setup self do
        integer :database_id,    :stored => true
        string  :boxview_url,    :stored => true
        string  :boxview_type,   :stored => true
        text    :boxview_title,  :stored => true
        text    :boxview_res_id, :stored => true

        string  :boxview_title
        text    :boxview_description, :stored => true
      end
      Sunspot.setup self, &block
    end

    def self.from(original)
      self.new(original.uri).tap {|o| o.original = original}
    end

    def initialize(uri)
      self.uri = uri
    end

    def original
      @original ||= original_class.new uri
    end
    attr_writer :original


    def original_class
      self.class.name.gsub(/SOLR::/, '').constantize
    rescue
      raise Exception, "This solr class does not seem to have a corresponding Talia class."
    end

    def boxview_url
      data = original.boxview_data
      return "/#{data[:url]}" if data[:url]
      action = data[:action] || "show"
      url_for(:only_path => true, :controller => data[:controller], :action => action, :id => original.id)
    end

    def boxview_title
      original.boxview_data[:title] || original.name
    end

    def boxview_description
      original.boxview_data[:description] || ""
    end

    def boxview_type
      original.boxview_data[:boxtype] || "image"
    end

    def boxview_res_id
      original.boxview_data[:res_id] || "#{original.class.name.underscore}_#{original.id}"
    end

    def database_id
      original.id
    end

    def solr_index
      Sunspot.index self
    end

    def solr_index!
      Sunspot.index! self
    end

    def iconclasses
      original.iconclasses(false).map {|i| i.pref_label} if original.respond_to? :iconclasses
    end # def iconclasses

    def method_missing(method)
      if original.respond_to? method
        original.send method unless method.to_s.ends_with? '='
      else
        super
      end
    end
    
    def bibliography
      bibliography_items.to_a.map {|item| item.bibliography_item.name}.compact
    end
  end
end
