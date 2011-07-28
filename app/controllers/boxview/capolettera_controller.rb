class Boxview::CapoletteraController < Boxview::BaseController
  def show
    @resource = PiLetterIllustrationCard.find_by_id params[:id]
    @image = @resource.image_zone.get_image_parent
  end
end
