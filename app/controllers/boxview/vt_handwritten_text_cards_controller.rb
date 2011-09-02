class Boxview::VtHandwrittenTextCardsController < Boxview::BaseController

  def index
    @resource = VtLetter.find_by_id params[:vt_letter_id]
    @cards   = @resource.handwritten_cards
    @edition = @resource.handwritten_reference_edition
  end

  def diplomatic
    @resource = VtHandwrittenTextCard.find_by_id params[:id];
    @letter   = @resource.letter
  end

  def critic
    @resource = VtHandwrittenTextCard.find_by_id params[:id];
    @letter   = @resource.letter

    @bibl = []
    @resource.bibliography_items.map do |item|
        @bibl.push render_to_string :partial => '/boxview/shared/custom_bibliography_item', :locals => {:custom => item, :item => item.bibliography_item}
    end

  end
end
