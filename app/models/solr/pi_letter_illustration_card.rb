module SOLR
  class PiLetterIllustrationCard < Base

    solr_setup do
      text :code
      text :collocation
      text :tecnique
      text :position
      text :description
      text :descriptive_notes
      text :image_components
      text :iconclasses
      text :study_notes
      text :bibliography
    end

    def iconclasses
      original.iconclasses false, false
    end

  end # class PiLetterIllustrationCard
end # module SOLR
