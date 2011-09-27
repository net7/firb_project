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
      # This does not come from Mixin::Facetable but is a Talia relation.
      text :transcription_text
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

  end # class PiIllustratedMdCard
end # module SOLR
