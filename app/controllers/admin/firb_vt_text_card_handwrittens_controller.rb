require 'simplyx'
require 'nokogiri'

class Admin::FirbVtTextCardHandwrittensController < Admin::FirbTextCardsController

  hobo_model_controller
  auto_actions :all

  def index
    @firb_vt_text_card_handwrittens = FirbVtTextCardHandwritten.paginate(:page => params[:page], :prefetch_relations => true)
  end

  def show
    @firb_vt_text_card_handwritten = FirbVtTextCardHandwritten.find(params[:id], :prefetch_relations => true)
  end
  
  def edit
    @full_type_name = "firb_vt_text_card_handwritten"
    @firb_vt_text_card_handwritten = FirbVtTextCardHandwritten.find(params[:id], :prefetch_relations => true)
  end

  def create
    notes = params[:firb_vt_text_card_handwritten].delete(:note)
    file = params[:firb_vt_text_card_handwritten].delete(:file)
    txt = FirbVtTextCardHandwritten.create_card(params[:firb_vt_text_card_handwritten])

    if(save_created!(txt))
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

    redirect_to :controller => :firb_vt_text_card_handwrittens, :action => :index
  end

  def destroy
    hobo_destroy { redirect_to :controller => :firb_vt_text_card_handwrittens, :action => :index }
  end

  def update
    notes = params[:firb_vt_text_card_handwritten].delete(:note)
    file = params[:firb_vt_text_card_handwritten].delete(:file)
    hobo_source_update do |updated_source|
      if (notes) 
        FirbNote.replace_notes(notes, updated_source)
      end
      
      updated_source.attach_file(file)
      updated_source.save!
      
      redirect_to :controller => :firb_vt_text_card_handwrittens, :action => :index
    end
  end

end