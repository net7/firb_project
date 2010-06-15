require 'simplyx'
require 'nokogiri'

class Admin::VtPrintedTextCardsController < Admin::TextCardsController

  hobo_model_controller
  auto_actions :all

  def index
    @vt_printed_text_cards = VtPrintedTextCard.paginate(:page => params[:page], :prefetch_relations => true)
  end

  def show
    @vt_printed_text_card = VtPrintedTextCard.find(params[:id], :prefetch_relations => true)
  end
  
  def edit
    @full_type_name = "vt_printed_text_card"
    @vt_printed_text_card = VtPrintedTextCard.find(params[:id], :prefetch_relations => true)
  end

  def create
    notes = params[:vt_printed_text_card].delete(:note)
    file = params[:vt_printed_text_card].delete(:file)
    txt = VtPrintedTextCard.create_card(params[:vt_printed_text_card])

    if(save_created(txt))
      flash[:notice] = "Text page succesfully created"
    else
      flash[:notice] = "Error creating the page"
    end

    if (err = txt.attach_file(file))
      flash[:notice] = err
    end

    if (notes)
      FirbNote.create_notes(notes.values, txt)
    end

    redirect_to :controller => :vt_printed_text_cards, :action => :index
  end

  def destroy
    hobo_destroy { redirect_to :controller => :vt_printed_text_card, :action => :index }
  end

  def update
    notes = params[:vt_printed_text_card].delete(:note)
    file = params[:vt_printed_text_card].delete(:file)
    hobo_source_update do |updated_source|
      if (notes) 
        FirbNote.replace_notes(notes, updated_source)
      end
      
      updated_source.attach_file(file)
      updated_source.save!
      
      redirect_to :controller => :vt_printed_text_card, :action => :index
    end
  end

end