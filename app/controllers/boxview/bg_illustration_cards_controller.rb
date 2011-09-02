class Boxview::BgIllustrationCardsController < Boxview::BaseController
  def show
    @resource = BgIllustrationCard.find_by_id params[:id]
    @image    = @resource.image_zone.get_parent
  end
end
