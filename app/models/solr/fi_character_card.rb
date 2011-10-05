module SOLR
  class FiCharacterCard < Base
    solr_setup do
      text :code
      text :collocation
      text :author
      text :tecnique
      text :description
      text :notes
      text :descriptive_notes
      text :study_notes      

      text :qualities_age
      text :qualities_gender
      text :qualities_profession
      text :qualities_ethnic_group

      text :image_components
      text :text_bibliography do 
        bibliography
      end

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


    def qualities_age
      original.qualities_age.to_s
    end

    def qualities_gender
      original.qualities_gender.to_s
    end

    def qualities_profession
      original.qualities_profession.to_s
    end

    def qualities_ethnic_group
      original.qualities_ethnic_group.to_s
    end

    
    def bibliography
      res =[]
      baldini_text.bibliography_items.to_a.each{|i| res << [i.bibliography_item.author, i.bibliography_item.title].join(', ')} if baldini_text.present?
      cini_text.bibliography_items.to_a.each{|i| res <<  [i.bibliography_item.author, i.bibliography_item.title].join(', ')} if cini_text.present?
      modern_bibliography_items.to_a.each{|i| res <<  [i.bibliography_item.author, i.bibliography_item.title].join(', ')} if modern_bibliography_items.present?
      res.compact
    end # def bibliography
  end # class FiCharacterCard
end # module SOLR
