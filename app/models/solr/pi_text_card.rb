module SOLR
  class PiTextCard < Base

    solr_setup do
      text :parafrasi
      text :transcription_text

      dynamic_string :image_components, :multiple => true, :stored => true do
        image_components
      end

      text :text_facets do
        facets
      end

      dynamic_string :facets, :multiple => true, :stored => true do
        facets
      end
    end

    def image_components
      result = {}
      original.non_illustrated_memory_depictions.to_a.each do |x|
        (result[x.depiction_type.to_s] ||= []) << x.short_description.to_s
      end
      result
    end

  end # class PiTextCard
end # module SOLR
