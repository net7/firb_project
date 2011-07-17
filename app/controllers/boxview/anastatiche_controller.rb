class Boxview::AnastaticheController < Boxview::BaseController
  def show
    @resource = Anastatica.find_by_id params[:id]
    @image = @resource.image_zone.get_image_parent
  end
end
