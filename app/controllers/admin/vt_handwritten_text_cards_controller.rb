require 'simplyx'
require 'nokogiri'

class Admin::VtHandwrittenTextCardsController < Admin::TextCardsController

  hobo_model_controller
  auto_actions :all

  def index
    @vt_handwritten_text_cards = VtHandwrittenTextCard.paginate(:page => params[:page], :prefetch_relations => true)
  end

  def show
    @vt_text_card_handwritten = VtHandwrittenTextCard.find(params[:id], :prefetch_relations => true)
  end
  
  def edit
    @full_type_name = "vt_handwritten_text_card"
    @vt_handwritten_text_card = VtHandwrittenTextCard.find(params[:id], :prefetch_relations => true)
  end

  def create
    notes = params[:vt_handwritten_text_card].delete(:note)
    file = params[:vt_handwritten_text_card].delete(:file)
    txt = VtHandwrittenTextCard.create_card(params[:vt_handwritten_text_card])

    if(save_created(txt))
      flash[:notice] = "Text page succesfully created"
    else
      flash[:notice] = "Error creating the page"
    end

    foo = txt.attach_file(file)
    flash[:notice] += "<br><br>" + foo if (foo)

    if (notes)
      Note.create_notes(notes.values, txt)
    end

    redirect_to :controller => :vt_handwritten_text_cards, :action => :index
  end

  def destroy
    hobo_destroy { redirect_to :controller => :vt_handwritten_text_cards, :action => :index }
  end

  def update
    notes = params[:vt_handwritten_text_card].delete(:note)
    file = params[:vt_handwritten_text_card].delete(:file)
    hobo_source_update do |updated_source|
      if (notes) 
        Note.replace_notes(notes, updated_source)
      else
        Note.delete_all_notes(updated_source)
      end
      
      updated_source.attach_file(file)
      updated_source.save!
      
      redirect_to :controller => :vt_handwritten_text_cards, :action => :index
    end
  end

end