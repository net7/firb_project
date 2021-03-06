require 'simplyx'
require 'nokogiri'

class Admin::FiTextCardsController < Admin::TextCardsController

  hobo_model_controller
  auto_actions :all

  cache_sweeper :fi_cards_sweeper

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
    hobo_source_create do |card|
      foo = card.attach_xml_file(file) if (file)
      flash[:notice] += foo if (foo)
      redirect_to :action => :index
    end
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

  def clean_funny_state
    FiProcession.all.each do |procession|
      if procession.count != procession.elements.count
        procession.each do |el|
          if el.nil?   
            puts "Procession #{procession.uri} aveva elementi nil"
            procession.delete el
          end
        end
        procession.save
      end 
    end
    render :layout => false, :text => 'Strange state should be fixed now'
  end


end
