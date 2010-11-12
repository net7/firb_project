require 'simplyx'
require 'nokogiri'

class Admin::FiTextCardsController < Admin::TextCardsController

  hobo_model_controller
  auto_actions :all

  def index
    @fi_text_cards = FiTextCard.paginate(:page => params[:page], :prefetch_relations => true)
  end

  def show
    @fi_text_card = FiTextCard.find(params[:id], :prefetch_relations => true)
  end
  
  def edit
    @full_type_name = "fi_text_card"
    @fi_text_card = FiTextCard.find(params[:id], :prefetch_relations => true)
  end

  def create
    file = params[:fi_text_card].delete(:file)
    txt = FiTextCard.create_card(params[:fi_text_card])

    if(save_created(txt))
      flash[:notice] = "Text page succesfully created"
    else
      flash[:notice] = "Error creating the page"
    end

    foo = txt.attach_xml_file(file)
    flash[:notice] += "<br><br>" + foo if (foo)

    redirect_to :controller => :fi_text_cards, :action => :index
  end

  def destroy
    hobo_destroy { redirect_to :controller => :fi_text_cards, :action => :index }
  end

  def update
    file = params[:fi_text_card].delete(:file)
    hobo_source_update do |updated_source|
      
      updated_source.attach_xml_file(file)
      updated_source.save!
      
      redirect_to :controller => :fi_text_cards, :action => :index
    end
  end

end