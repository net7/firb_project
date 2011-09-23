class Boxview::VtSearchController < Boxview::BaseController
  def results
    @q = params[:q].try(:strip)
    # Note: contrary to what the documentation says, 
    # it seems you _have_ to specify the block argument.
    @search = SOLR.search(SOLR::VtHandwrittenTextCard, SOLR::VtPrintedTextCard, SOLR::VtLetter) do |s|
      s.keywords @q
    end
  end
end
