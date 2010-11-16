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
    hobo_source_create do |card|
      foo = card.attach_xml_file(file) if (file)
      Note.create_notes(card, notes) if (notes)
      flash[:notice] += foo if (foo)
      redirect_to :action => :index
    end
  end

  def destroy
    hobo_destroy { redirect_to :controller => :vt_printed_text_cards, :action => :index }
    #    hobo_destroy { redirect_to :controller => :vt_printed_text_cards }
  end

  def update
    notes = params[:vt_printed_text_card].delete(:note)
    file = params[:vt_printed_text_card].delete(:file)
    hobo_source_update do |updated_source|
      if (notes) 
        Note.replace_notes(notes, updated_source)
      else
        Note.delete_all_notes(updated_source)
      end
      
      updated_source.attach_xml_file(file)
      updated_source.save!
      
      redirect_to :controller => :vt_printed_text_cards, :action => :index
    end
  end

end