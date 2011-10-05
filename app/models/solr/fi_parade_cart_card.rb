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
        bibliography_full_text
      end

      string :image_components, :multiple => true
      string :bibliography, :multiple => true, :stored => true
    end

    def image_components
      original.image_components.to_a
    end

    def bibliography
      res =[]
      baldini_text.bibliography_items.to_a.each{|i| res << [i.bibliography_item.author, i.bibliography_item.title].join(', ')} if baldini_text.present?
      cini_text.bibliography_items.to_a.each{|i| res <<  [i.bibliography_item.author, i.bibliography_item.title].join(', ')} if cini_text.present?
      modern_bibliography_items.to_a.each{|i| res <<  [i.bibliography_item.author, i.bibliography_item.title].join(', ')} if modern_bibliography_items.present?
      res.compact
    end # def bibliography
  end # class FiParadeCartCard
end # module SOLR
