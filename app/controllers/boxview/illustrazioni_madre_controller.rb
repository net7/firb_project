class Boxview::IllustrazioniMadreController < Boxview::BaseController
  def show
    @resource = PiIllustrationCard.find_by_id params[:id]
    @zone     = @resource.image_zone
    @image    = @zone.get_image_parent
    @children = PiIllustratedMdCard.find(:all, :find_through => [N::TALIA.parent_card, @resource.uri])
  end
end
