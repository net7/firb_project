class Boxview::FiCharacterCardsController < Boxview::BaseController

  caches_page :show


  def show
    @resource = FiCharacterCard.find_by_id params[:id]
    @image    = @resource.image_zone.get_image_parent
  end
end
