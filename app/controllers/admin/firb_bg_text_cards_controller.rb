require 'simplyx'
require 'nokogiri'

class Admin::FirbBgTextCardsController < Admin::FirbTextCardsController

  hobo_model_controller
  auto_actions :all

  def index
    @firb_bg_text_cards = FirbBgTextCard.paginate(:page => params[:page], :prefetch_relations => true)
  end

  def show
    @firb_bg_text_card = FirbBgTextCard.find(params[:id], :prefetch_relations => true)
  end
  
  def edit
    @full_type_name = "firb_bg_text_card"
    @firb_bg_text_card = FirbBgTextCard.find(params[:id], :prefetch_relations => true)
  end

  def create
    file = params[:firb_bg_text_card].delete(:file)
    txt = FirbBgTextCard.create_card(params[:firb_bg_text_card])

    if(save_created!(txt))
      flash[:notice] = "Text page succesfully created"
    else
      flash[:notice] = "Error creating the page"
    end

    if (err = txt.attach_file(file))
      flash[:notice] = err
    end

    redirect_to :controller => :firb_bg_text_cards, :action => :index
  end

  def destroy
    hobo_destroy { redirect_to :controller => :firb_bg_text_cards, :action => :index }
  end

  def update
    file = params[:firb_bg_text_card].delete(:file)
    hobo_source_update do |updated_source|
      
      updated_source.attach_file(file)
      updated_source.save!
      
      redirect_to :controller => :firb_bg_text_cards, :action => :index
    end
  end

end