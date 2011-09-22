module SOLR
  class VtHandwrittenTextCard < Base
    solr_setup do
      text :signature
      text :watermark
      text :technical_notes
      text :conservation_status
      text :bibliography

      string :bibliography, :multiple => true

      dynamic_string :facets, :multiple => true, :stored => true do
        facets
      end

      # Other fields (filters?)
      # measure
      # cartulation
      # autography ("Completa" for all cards?)
      # date
    end

    def bibliography
      bibliography_items.to_a.map do |item|
        [].tap do |parts|
          parts << item.bibliography_item.published_in.to_s
          parts << item.bibliography_item.publisher.to_s
          parts << item.bibliography_item.date.to_s
          parts << item.pages.to_s
        end.compact.join ', '
      end
    end
  end
end
