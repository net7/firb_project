module SOLR
  class VtPrintedTextCard < Base
    solr_setup do
      text :ref_edition
      text :name

      text :text_facets do
        facets
      end
      dynamic_string :facets, :multiple => true, :stored => true do
        facets
      end
      text :transcription_text

    end

    def ref_edition
      ::VtLetter.edition_title_for bibliography_items.first
    end

  end # class VtPrintedTextCard
end # module SOLR
