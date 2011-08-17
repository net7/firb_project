class Boxview::FiTextCardsController < Boxview::BaseController
  include BoxviewHelper

  def show
    @resource = FiTextCard.find_by_id params[:id]
  end

  def boxview_data
    { :controller => 'boxview/fi_text_cards',
      :title => "TEXT CARD",
      :description => "TEXT CARD",
      :res_id => "fi_text_card_#{self.id}", 
      :box_type => nil,
      :thumb => nil
    }
  end
end
