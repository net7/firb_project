module SOLR
  class FiParadeCartCard < Base
    solr_setup do
      text :code
      text :collocation
      text :author
      text :tecnique
      text :descriptive_notes
      text :description
      text :notes
      text :study_notes

      text :iconclasses

      text :image_components
      text :text_bibliography do 
        bibliography
      end

      string :image_components, :multiple => true
      string :bibliography, :multiple => true, :stored => true
    end

    def image_components
      original.image_components.to_a
    end

    def bibliography
      super.tap do |biblio|
        biblio + baldini_text.bibliography_items.map {|item| item.bibliography_item.name} if baldini_text
        biblio + cini_text.bibliography_items.map {|item| item.bibliography_item.name} if cini_text
        biblio + modern_bibliography_items.map {|item| item.bibliography_item.name} if modern_bibliography_items
      end.compact
    end # def bibliography
  end # class FiParadeCartCard
end # module SOLR
