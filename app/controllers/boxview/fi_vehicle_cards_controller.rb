class Boxview::FiVehicleCardsController < Boxview::BaseController
  def show
    @resource = FiVehicleCard.find_by_id params[:id]
    @image    = @resource.image_zone.get_parent
  end
end
