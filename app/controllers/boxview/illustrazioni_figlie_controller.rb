class Boxview::IllustrazioniFiglieController < Boxview::BaseController
  def show
    @resource = PiIllustratedMdCard.find_by_id params[:id]
    @zone     = @resource.image_zone
    @image    = @zone.get_image_parent
  end
end
