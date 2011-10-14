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
      text :text_bibliography do
        bibliography_full_text
      end

      dynamic_string :image_components, :multiple => true, :stored => true do
        image_components
      end
    end

    def iconclasses
      original.iconclasses false
    end

    def image_components
      result = {}
      original.image_components.to_a.each do |x|
        (result[x.zone_type.to_s] ||= []) << x.name.to_s
      end
      result
    end
  end # class PiIllustratedMdCard
end # module SOLR
