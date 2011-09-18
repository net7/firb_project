module SOLR
  class VtLetter < Base
    solr_setup do
      # Note that :title is not included, I expect that :boxview_title, 
      # being what is actually shown, is the best candidate for that place.
      # To see what is automatically setup, see base.rb, method self.solr_setup.
      text :date_string, :stored => true
    end
  end
end
