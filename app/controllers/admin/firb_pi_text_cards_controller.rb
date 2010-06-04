require 'simplyx'
require 'nokogiri'

class Admin::FirbPiTextCardsController < Admin::AdminSiteController

  hobo_model_controller
  auto_actions :all

  def index
    @firb_pi_text_cards = FirbPiTextCard.paginate(:page => params[:page], :prefetch_relations => true)
  end
  
  def show
    @firb_pi_text_card = FirbPiTextCard.find(params[:id], :prefetch_relations => true)
  end

  def show_annotable
    record = TaliaCore::DataTypes::DataRecord.find(params[:id])
    @content = record.content_string
  end

  def create
    notes = params[:firb_pi_text_card].delete(:note)
    txt = FirbPiTextCard.create_card(params[:firb_pi_text_card])
    
    if(save_created!(txt))
      flash[:notice] = "Text page succesfully created"
    else
      flash[:notice] = "Error creating the page"
    end
    
    attach_file_to(txt)

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
    hobo_source_update do |updated_source|
    if (notes) 
        FirbNote.replace_notes(notes, updated_source)
    end
    redirect_to :controller => :firb_pi_text_cards, :action => :index
  end
  end
  
  private
  
  def attach_file_to(text_card)
    if(params[:firb_pi_text_card][:file])
      
      xml_file = File.open(params[:firb_pi_text_card][:file].path())
      doc = Nokogiri::XML(xml_file)
      schema  = Nokogiri::XML::RelaxNG(File.open('xslt/swicky_tei.rng'))
      error_string = "The XML source has not been attached to '#{text_card.title}' since it's not well formed. Hints:"+"<br><ul>"
      schema.validate(doc).each do |error|
        error_string += "<li>" + error.message + "</li>"
      end
      error_string += "</ul>"

      if (schema.valid?(doc)) 
        xml_data = TaliaCore::DataTypes::XmlData.new
        xml_data.create_from_data('data.xml', params[:firb_pi_text_card][:file], :options => { :mime_type => 'text/xml' })
        text_card.data_records.destroy_all
        text_card.data_records << xml_data
        options = {"source_uri" => text_card.uri.to_s }
        xsl_file = 'xslt/HTML1.xsl'
        xml_file = xml_data.full_filename
        html1 = Simplyx::XsltProcessor::perform_transformation(xsl_file, xml_file, options)
        html1_data = TaliaCore::DataTypes::XmlData.new
        html1_data.create_from_data('html1.html', html1, :options => { :mime_type => 'text/html' })
        text_card.data_records << html1_data
        text_card.save!
      else
        flash[:notice] = error_string
      end
    end
  end

end