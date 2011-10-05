module SOLR
  class FiTextCard < Base
    solr_setup do
      text :text_bibliography do 
        bibliography
      end

      text :transcription_text
      text :facets

      string :bibliography, :multiple => true, :stored => true
      dynamic_string :facets, :multiple => true, :stored => true do
        facets
      end
    end # solr_setup do

  end # class FiTextCard
end # SOLR
