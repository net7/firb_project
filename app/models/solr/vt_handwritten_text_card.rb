module SOLR
  class VtHandwrittenTextCard < Base
    solr_setup do
      text :signature
      text :watermark
      text :technical_notes
      text :conservation_status
      text :text_bibliography do
        bibliography
      end

      text :text_facets do
        facets
      end
      dynamic_string :facets, :multiple => true, :stored => true do
        facets
      end
      text :transcription_text

      # Other fields (filters?)
      # measure
      # cartulation
      # autography ("Completa" for all cards?)
      # date
    end
  end # class VtHandwrittenTextCard
end # module SOLR
