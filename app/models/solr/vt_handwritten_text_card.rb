module SOLR
  class VtHandwrittenTextCard < Base
    solr_setup do
      text :signature
      text :watermark
      text :technical_notes
      text :conservation_status
      text :bibliography

      text :facets
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
