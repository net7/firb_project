module SOLR
  class PiIllustrationCard < Base
    solr_setup do
      text :code,              :stored => true
      text :collocation,       :stored => true
      text :tecnique,          :stored => true
      text :position,          :stored => true
      text :image_components,  :stored => true
      text :description,       :stored => true
      text :descriptive_notes, :stored => true
    end
  end
end
