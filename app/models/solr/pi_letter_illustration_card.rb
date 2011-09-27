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

      dynamic_string :image_components, :multiple => true, :stored => true do
        original.image_components.reduce({}) {|x, y| x.merge(y.zone_type.to_s => y.name.to_s)}
      end
    end

    def iconclasses
      original.iconclasses false, false
    end

  end # class PiLetterIllustrationCard
end # module SOLR
