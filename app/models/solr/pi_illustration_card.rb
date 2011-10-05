module SOLR
  class PiIllustrationCard < Base

    solr_setup do
      text :code
      text :collocation
      text :tecnique
      text :position
      text :image_components
      text :description
      text :descriptive_notes
      text :memory_components
      text :iconclasses
      text :study_notes
      text :text_bibliography do
        bibliography
      end

      dynamic_string :image_components, :multiple => true, :stored => true do
        image_components
      end
    end

    def memory_components
      [].tap do |results|
        children_components_by_type.each do |type, components|
          components.each do |component|
            results << component.name.to_s
          end
        end
      end
    end # def memory_components

    def image_components
      result = {}
      original.image_components.to_a.each do |x|
        (result[x.zone_type.to_s] ||= []) << x.name.to_s
      end
      result
    end

  end # class PiIllustrationCard
end # module SOLR
