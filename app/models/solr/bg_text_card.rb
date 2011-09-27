module SOLR
  class BgTextCard < Base
    solr_setup do
      text :collocation
      text :comment
      text :transcription_text
    end
  end # class BgTextCard
end # SOLR
