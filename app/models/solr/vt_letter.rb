module SOLR
  class VtLetter < Base
    solr_setup do
      text :edition_title
      text :printed_collocation
    end

    def edition_title
      ::VtLetter.edition_title_for handwritten_reference_edition
    end
  end
end
