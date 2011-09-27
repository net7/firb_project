module SOLR
  class FiAnimalCard < Base
    solr_setup do
      text :bibliography
      text :image_components

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
      end.compact
    end # def bibliography
  end # class FiAnimalCard
end # module SOLR
