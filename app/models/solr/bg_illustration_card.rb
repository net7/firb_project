module SOLR
  class BgIllustrationCard < Base
    solr_setup do
      text :signature
      text :collocation
      text :tecnique
      text :descriptive_notes
      text :author
      text :study_notes
      text :motto_translation
      text :owner
      text :original_meaning
      text :contextual_meaning
      text :copyright_notes
      text :text_bibliography do
        bibliography_full_text
      end
      text :transcription_text
      text :facets

      string :bibliography, :multiple => true, :stored => true
      dynamic_string :facets, :multiple => true, :stored => true do
        facets
      end
    end
  end # class BgTextCard
end # SOLR
