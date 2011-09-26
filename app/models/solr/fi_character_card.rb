module SOLR
  class FiCharacterCard < Base
    solr_setup do
      text :qualities_age
      text :qualities_gender
      text :qualities_profession
      text :qualities_ethnic_group
      text :image_components
      text :bibliography

      string :qualities_age
      string :qualities_gender
      string :qualities_profession
      string :qualities_ethnic_group
      string :image_components, :multiple => true
      string :bibliography, :multiple => true, :stored => true
    end

    def bibliography
      super +
        baldini_text.bibliography_items.map {|item| item.bibliography_item.name}.compact +
        cini_text.bibliography_items.map    {|item| item.bibliography_item.name}.compact +
        modern_bibliography_items.map       {|item| item.bibliography_item.name}.compact
    end # def bibliography
  # end class FiCharacterCard
end # module SOLR
