require 'simplyx'
require 'nokogiri'

class Admin::PiTextCardsController < Admin::TextCardsController

  hobo_model_controller
  auto_actions :all

  def index
    @pi_text_cards = PiTextCard.paginate(:page => params[:page], :prefetch_relations => true)
  end

  def show
    @pi_text_card = PiTextCard.find(params[:id], :prefetch_relations => true)
  end

  def create
    notes = params[:pi_text_card].delete(:note)
    file = params[:pi_text_card].delete(:file)
    txt = PiTextCard.create_card(params[:pi_text_card])

    if(save_created(txt))
      flash[:notice] = "Text page succesfully created"
    else
      flash[:notice] = "Error creating the page"
    end

    txt.attach_file(file)

    if (notes)
      FirbNote.create_notes(notes.values, txt)
    end

    redirect_to :controller => :pi_text_cards, :action => :index
  end

  def destroy
    hobo_destroy { redirect_to :controller => :pi_text_cards, :action => :index }
  end

  def update
    notes = params[:pi_text_card].delete(:note)
    file = params[:pi_text_card].delete(:file)
    hobo_source_update do |updated_source|
      if (notes) 
        FirbNote.replace_notes(notes, updated_source)
      end
      
      updated_source.attach_file(file)
      updated_source.save!
      
      redirect_to :controller => :pi_text_cards, :action => :index
    end
  end

end