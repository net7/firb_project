module SOLR
  class PiTextCard < Base

    solr_setup do
      text :parafrasi
      text :facets
      text :transcription_text

      dynamic_string :image_components, :multiple => true, :stored => true do
        facets
      end

      # dynamic_string :facets, :multiple => true, :stored => true do
      #   facets
      # end
    end

  end # class PiTextCard
end # module SOLR
