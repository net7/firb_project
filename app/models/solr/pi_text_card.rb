module SOLR
  class PiTextCard < Base

    solr_setup do
      text :parafrasi

      text :facets
      dynamic_string :facets, :multiple => true, :stored => true do
        facets
      end
      dynamic_string :facet_labels, :multiple => true, :stored => true do
        facets
      end
      text :transcription_text
    end

  end # class PiTextCard
end # module SOLR
