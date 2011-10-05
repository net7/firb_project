class Boxview::BibliographyItemController < Boxview::BaseController

#  caches_page :show

  def show
    cbi = CustomBibliographyItem.find_by_id params[:id]
    @resource = cbi.bibliography_item
  end
end
