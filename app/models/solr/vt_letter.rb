module SOLR
  class VtLetter < Base
    ::Sunspot.setup self do
      text :title,       :stored => true
      text :date_string, :stored => true
    end
  end
end


