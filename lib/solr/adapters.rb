module SunspotAdapters
  class Instance < Sunspot::Adapters::InstanceAdapter
    def id
      @instance.uri.to_s if @instance.respond_to? :uri
    end
  end

  class DataAccessor < Sunspot::Adapters::DataAccessor
    def load(id)
      @clazz.new id.to_s
    end
  end
end
