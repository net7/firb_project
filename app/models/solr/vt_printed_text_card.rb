module SOLR
  class VtPrintedTextCard < Base
    solr_setup do
      text :ref_edition
      text :name
      # text :page_position

      dynamic_string :facets, :multiple => true, :stored => true do
        facets
      end
    end

    def edition_ref
      VtLetter.edition_title_for bibliography_items.first
    end

  end # class VtPrintedTextCard
end # module SOLR
