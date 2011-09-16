class Boxview::FiParadeCartCardsController < Boxview::BaseController

  caches_page :show

  def show
    @resource = FiParadeCartCard.find_by_id params[:id]
    @image    = @resource.image_zone.get_parent
  end
end
