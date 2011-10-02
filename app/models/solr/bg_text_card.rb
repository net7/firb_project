module SOLR
  class BgTextCard < Base
    solr_setup do
      text :comment
      text :page_position
      text :transcription_text
    end
  end # class BgTextCard
end # SOLR
