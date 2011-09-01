class Boxview::FiAnimalCardsController < Boxview::BaseController

  def show
    @resource = FiAnimalCard.find_by_id params[:id]
    @image    = @resource.image_zone.get_parent
  end
end
