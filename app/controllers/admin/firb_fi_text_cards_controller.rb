require 'simplyx'
require 'nokogiri'

class Admin::FirbFiTextCardsController < Admin::FirbTextCardsController

  hobo_model_controller
  auto_actions :all

  def index
    @firb_fi_text_cards = FirbFiTextCard.paginate(:page => params[:page], :prefetch_relations => true)
  end

  def show
    @firb_fi_text_card = FirbFiTextCard.find(params[:id], :prefetch_relations => true)
  end
  
  def edit
    @full_type_name = "firb_fi_text_card"
    @firb_fi_text_card = FirbFiTextCard.find(params[:id], :prefetch_relations => true)
  end

  def create
    file = params[:firb_fi_text_card].delete(:file)
    txt = FirbFiTextCard.create_card(params[:firb_fi_text_card])

    if(save_created(txt))
      flash[:notice] = "Text page succesfully created"
    else
      flash[:notice] = "Error creating the page"
    end

    if (err = txt.attach_file(file))
      flash[:notice] = err
    end

    redirect_to :controller => :firb_fi_text_cards, :action => :index
  end

  def destroy
    hobo_destroy { redirect_to :controller => :firb_fi_text_cards, :action => :index }
  end

  def update
    file = params[:firb_fi_text_card].delete(:file)
    hobo_source_update do |updated_source|
      
      updated_source.attach_file(file)
      updated_source.save!
      
      redirect_to :controller => :firb_fi_text_cards, :action => :index
    end
  end

end