class Boxview::FiEpisodeCardsController < Boxview::BaseController
  include ImtHelper
  include BoxviewHelper

  def show
    @resource = FiEpisodeCard.find_by_id params[:id]
    @image    = @resource.image_zone.get_parent
  end
end
