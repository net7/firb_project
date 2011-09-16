class Boxview::FiThroneCardsController < Boxview::BaseController

  caches_page :show

  def show
    @resource = FiThroneCard.find_by_id params[:id]
    @image    = @resource.image_zone.get_parent
  end
end
