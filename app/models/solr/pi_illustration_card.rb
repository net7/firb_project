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
      text :bibliography

      dynamic_string :image_components, :multiple => true, :stored => true do
        original.image_components.reduce({}) {|x, y| x.merge(y.zone_type.to_s => y.name.to_s)}
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
  end # class PiIllustrationCard
end # module SOLR
