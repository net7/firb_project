class Boxview::VtSearchController < Boxview::BaseController
  def results
    @q = params[:q].try(:strip)
    # Note: contrary to what the documentation says, 
    # it seems you _have_ to specify the block argument.
    @search = Sunspot.search(SOLR::VtLetter) do |s|
      s.keywords @q do
        highlight :title, :date_string
      end
    end
  end
end
