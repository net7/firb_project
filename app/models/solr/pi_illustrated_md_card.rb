module SOLR
  class PiIllustratedMdCard < Base

    solr_setup do
      text :code
      text :collocation
      text :tecnique
      text :position
      text :descriptive_notes
      text :description
      text :image_components
      text :transcription_text
      text :iconclasses
      text :study_notes
      text :bibliography
    end

    def iconclasses
      original.iconclasses false, false
    end

  end # class PiIllustratedMdCard
end # module SOLR
