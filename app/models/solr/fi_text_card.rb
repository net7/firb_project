module SOLR
  class FiTextCard < Base
    solr_setup do
      text :bibliography
      string :bibliography, :multiple => true, :stored => true
    end
  end # class FiTextCard
end # SOLR
