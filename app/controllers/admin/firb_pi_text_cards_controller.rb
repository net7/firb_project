require 'simplyx'
require 'nokogiri'

class Admin::FirbPiTextCardsController < Admin::FirbTextCardsController

  hobo_model_controller
  auto_actions :all

  def index
    @firb_pi_text_cards = FirbPiTextCard.paginate(:page => params[:page], :prefetch_relations => true)
  end

  def show
    @firb_pi_text_card = FirbPiTextCard.find(params[:id], :prefetch_relations => true)
  end

  def create
    notes = params[:firb_pi_text_card].delete(:note)
    file = params[:firb_pi_text_card].delete(:file)
    txt = FirbPiTextCard.create_card(params[:firb_pi_text_card])

    if(save_created(txt))
      flash[:notice] = "Text page succesfully created"
    else
      flash[:notice] = "Error creating the page"
    end

    txt.attach_file(file)

    if (notes)
      FirbNote.create_notes(notes.values, txt)
    end

    redirect_to :controller => :firb_pi_text_cards, :action => :index
  end

  def destroy
    hobo_destroy { redirect_to :controller => :firb_pi_text_cards, :action => :index }
  end

  def update
    notes = params[:firb_pi_text_card].delete(:note)
    file = params[:firb_pi_text_card].delete(:file)
    hobo_source_update do |updated_source|
      if (notes) 
        FirbNote.replace_notes(notes, updated_source)
      end
      
      updated_source.attach_file(file)
      updated_source.save!
      
      redirect_to :controller => :firb_pi_text_cards, :action => :index
    end
  end

end