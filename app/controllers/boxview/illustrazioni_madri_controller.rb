class Boxview::IllustrazioniMadriController < Boxview::BaseController
  def show
    @resource = PiIllustrationCard.find_by_id params[:id]
    @zone     = @resource.image_zone
    @image    = @zone.get_image_parent
  end
end
