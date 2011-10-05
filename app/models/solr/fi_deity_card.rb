module SOLR
  class FiDeityCard < Base
    solr_setup do
      text :code
      text :collocation
      text :author
      text :tecnique
      text :descriptive_notes
      text :study_notes      

      text :image_components
      text :bibliography

      text :iconclasses
      text :text_bibliography do 
        bibliography_full_text
      end
      text :image_components

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
      res.compact
    end # def bibliography
  end # class FiDeityCard
end # module SOLR
