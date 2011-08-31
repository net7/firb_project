class Boxview::VtHandwrittenTextCardsController < Boxview::BaseController
  def index
    @resource = VtLetter.find_by_id params[:vt_letter_id]
    @cards   = @resource.handwritten_cards
    @edition = @resource.handwritten_reference_edition
  end
end
