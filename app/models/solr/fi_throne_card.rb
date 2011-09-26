module SOLR
  class FiThroneCard < Base
    solr_setup do
      text :bibliography
      text :image_components

      string :image_components, :multiple => true
      string :bibliography, :multiple => true, :stored => true
    end

    def bibliography
      super +
        baldini_text.bibliography_items.map {|item| item.bibliography_item.name}.compact +
        cini_text.bibliography_items.map    {|item| item.bibliography_item.name}.compact
    end # def bibliography
  # end class FiThroneCard
end # module SOLR
