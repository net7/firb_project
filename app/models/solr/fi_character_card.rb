module SOLR
  class FiCharacterCard < Base
    solr_setup do
      string :qualities_age
      string :qualities_gender
      string :qualities_profession
      string :qualities_ethnic_group
      string :collocation
      string :descriptive_notes
      string :tecnique
      string :code
      string :description

      text :bibliography
      string :bibliography, :multiple => true

      text :transcription
      text :name

      text :facets
      dynamic_string :facets, :multiple => true, :stored => true do
        facets
      end
    end # solr_setup

    def bibliography
      parts = []
      baldini_text.bibliography_items.to_a.map do |item|
          parts << item.bibliography_item.published_in.to_s
          parts << item.bibliography_item.publisher.to_s
          parts << item.bibliography_item.date.to_s
          parts << item.pages.to_s
      end
      cini_text.bibliography_items.to_a.map do |item|
          parts << item.bibliography_item.published_in.to_s
          parts << item.bibliography_item.publisher.to_s
          parts << item.bibliography_item.date.to_s
          parts << item.pages.to_s
      end
      res.compact.join ', '
    end # bibliography


  end # class FiCharacterCard
end # module SOLR
