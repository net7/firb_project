class Admin::FirbTextCardsController < Admin::AdminSiteController

  hobo_model_controller

  auto_actions :all

  def create
    txt = FirbTextCard.create_card(params[:firb_text_card][:parafrasi], params[:firb_text_card][:anastatica], params[:firb_text_card][:image_zone])
    
    if(txt.save)
      flash[:notice] = "Text page succesfully created"
    else
      flash[:notice] = "Error creating the page"
    end

    if (params[:firb_text_card][:note])
      FirbNote.create_notes(params[:firb_text_card][:note], txt)
    end
    redirect_to :controller => :firb_text_cards
  end

  def remove_page
    p = FirbTextCard.find(params[:id])
    if (p.remove)
      flash[:notice] = "Text page removed"
    else
      flash[:notice] = "Error removing the text page"
    end
    redirect_to :controller => :firb_text_cards
  end

  def update
    p = FirbTextCard.find(params[:id])
    p.anastatica = FirbAnastaticaPage.find(params[:firb_text_card][:anastatica])
    p.image_zone = FirbImageZone.find(params[:firb_text_card][:image_zone])
    
    if (params[:firb_text_card][:note]) 
      FirbNote.replace_notes(params[:firb_text_card][:note], p)
    end

    if (p.save!)
      flash[:notice] = "Text page updated"
    else
      flash[:notice] = "Error updating the text page"
    end
    redirect_to :controller => :firb_text_cards
  end

end