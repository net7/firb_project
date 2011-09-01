class Boxview::VtLettersController < Boxview::BaseController
  def show
    redirect_to vt_letter_vt_handwritten_text_cards_url(params[:id])
  end
end
