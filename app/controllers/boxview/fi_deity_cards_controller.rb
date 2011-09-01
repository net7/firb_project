class Boxview::FiDeityCardsController < Boxview::BaseController

  def show
    @resource = FiDeityCard.find_by_id params[:id]
    @image    = @resource.image_zone.get_parent
  end
end
