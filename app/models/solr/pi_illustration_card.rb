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
    end

  end
end
