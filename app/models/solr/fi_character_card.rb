module SOLR
  class FiCharacterCard < Base
    solr_setup do
      text :qualities_age
      text :qualities_gender
      text :qualities_profession
      text :qualities_ethnic_group
      text :image_components
      text :bibliography

      string :qualities_age, :stored => true
      string :qualities_gender, :stored => true
      string :qualities_profession, :stored => true
      string :qualities_ethnic_group, :stored => true
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
  end # class FiCharacterCard
end # module SOLR
