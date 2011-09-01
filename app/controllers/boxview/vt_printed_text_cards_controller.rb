class Boxview::VtPrintedTextCardsController < Boxview::BaseController
  def index
    @resource = VtLetter.find_by_id params[:vt_letter_id]
    @cards   = @resource.printed_cards
    @edition = @resource.printed_reference_edition
  end

  def show
    @resource = VtPrintedTextCard.find_by_id params[:id];
    @letter   = @resource.letter
    @edition  = @resource.bibliography_items.blank? ? nil : @resource.bibliography_items.first
  end
end
