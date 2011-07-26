class Boxview::IllustrazioniFiglieController < Boxview::BaseController
  def show
    @resource = PiIllustratedMdCard.find_by_id params[:id]
  end
end
