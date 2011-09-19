class Boxview::FiEpisodeCardsController < Boxview::BaseController

  caches_page :show

  def show
    @resource = FiEpisodeCard.find_by_id params[:id]
    @image    = @resource.image_zone.get_image_parent
  end
end
