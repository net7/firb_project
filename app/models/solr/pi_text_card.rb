module SOLR
  class PiTextCard < Base

    solr_setup do
      text :parafrasi
      text :facets
      text :transcription_text

      dynamic_string :image_components, :multiple => true, :stored => true do
        original.non_illustrated_memory_depictions.reduce({}) {|x, y| x.merge(y.depiction_type.to_s => y.short_description.to_s)}
      end

      # dynamic_string :facets, :multiple => true, :stored => true do
      #   facets
      # end
    end

  end # class PiTextCard
end # module SOLR
