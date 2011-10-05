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
      text :text_bibliography do
        bibliography_full_text
      end

      dynamic_string :image_components, :multiple => true, :stored => true do
        image_components
      end
    end

    def iconclasses
      original.iconclasses false, false
    end

    def image_components
      result = {}
      original.image_components.to_a.each do |x|
        (result[x.zone_type.to_s] ||= []) << x.name.to_s
      end
      result
    end
  end # class PiLetterIllustrationCard
end # module SOLR
