require 'simplyx'
require 'nokogiri'

class Admin::BgTextCardsController < Admin::TextCardsController

  hobo_model_controller
  auto_actions :all

  def index
    @bg_text_cards = BgTextCard.paginate(:page => params[:page], :prefetch_relations => true)
  end

  def show
    @bg_text_card = BgTextCard.find(params[:id], :prefetch_relations => true)
  end
  
  def edit
    @full_type_name = "bg_text_card"
    @bg_text_card = BgTextCard.find(params[:id], :prefetch_relations => true)
  end

  def create
    file = params[:bg_text_card].delete(:file)
    txt = BgTextCard.create_card(params[:bg_text_card])

    if(save_created(txt))
      flash[:notice] = "Text page succesfully created"
    else
      flash[:notice] = "Error creating the page"
    end

    if (err = txt.attach_file(file))
      flash[:notice] = err
    end

    redirect_to :controller => :bg_text_cards, :action => :index
  end

  def destroy
    hobo_destroy { redirect_to :controller => :bg_text_cards, :action => :index }
  end

  def update
    file = params[:bg_text_card].delete(:file)
    hobo_source_update do |updated_source|
      
      updated_source.attach_file(file)
      updated_source.save!
      
      redirect_to :controller => :bg_text_cards, :action => :index
    end
  end

end