module SOLR
  class FiParadeCartCard < Base
    solr_setup do
      text :image_components
      text :bibliography

      string :image_components, :multiple => true
      string :bibliography, :multiple => true, :stored => true
    end

    def bibliography
      super +
        baldini_text.bibliography_items.map {|item| item.bibliography_item.name}.compact +
        cini_text.bibliography_items.map    {|item| item.bibliography_item.name}.compact +
        modern_bibliography_items.map       {|item| item.bibliography_item.name}.compact
    end # def bibliography
  # end class FiParadeCartCard
end # module SOLR
