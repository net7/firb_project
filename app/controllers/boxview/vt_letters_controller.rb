class Boxview::VtLettersController < Boxview::BaseController
  def show
    @resource = VtLetter.find_by_id params[:id]   
  end
end
