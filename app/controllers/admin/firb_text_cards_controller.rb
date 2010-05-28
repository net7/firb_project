require 'simplyx'
require 'Nokogiri'

class Admin::FirbTextCardsController < Admin::AdminSiteController

  hobo_model_controller
  

  auto_actions :all

  def index
    @firb_text_cards = FirbTextCard.paginate(:page => params[:page], :prefetch_relations => true)
  end
  
  def show
    @firb_text_card = FirbTextCard.find(params[:id], :prefetch_relations => true)
  end

  def show_annotable
    record = TaliaCore::DataTypes::DataRecord.find(params[:id])
    @content = record.content_string
  end

  def create
    txt = FirbTextCard.create_card(params[:firb_text_card][:title], params[:firb_text_card][:parafrasi], params[:firb_text_card][:anastatica], params[:firb_text_card][:image_zone])
    
    if(save_created!(txt))
      flash[:notice] = "Text page succesfully created"
    else
      flash[:notice] = "Error creating the page"
    end
    
    attach_file_to(txt)

    if (params[:firb_text_card][:note])
      FirbNote.create_notes(params[:firb_text_card][:note].values, txt)
    end
    
    redirect_to :controller => :firb_text_cards, :action => :index
  end

  def destroy
    hobo_destroy { redirect_to :controller => :firb_text_cards, :action => :index }
  end

  def update
    text_card = FirbTextCard.find(params[:id])
    
    text_card.updatable_by?(current_user) or raise Hobo::PermissionDeniedError, "#{self.class.name}#update"
    
    text_card.anastatica = FirbAnastaticaPage.find(params[:firb_text_card][:anastatica]) unless(params[:firb_text_card][:anastatica].blank?)
    text_card.parafrasi = params[:firb_text_card][:parafrasi] unless(params[:firb_text_card][:parafrasi].blank?)
    text_card.title = params[:firb_text_card][:title] unless(params[:firb_text_card][:title].blank?)

    #TODO: is it ok to do nothing in case this is nil?
    unless params[:firb_text_card][:image_zone].nil?
      zones = params[:firb_text_card][:image_zone].values.collect{ |iz| FirbImageZone.find(iz) }
      text_card.predicate_replace(:dct, :isFormatOf, zones)
    end

    if (params[:firb_text_card][:note]) 
      FirbNote.replace_notes(params[:firb_text_card][:note], text_card)
    end

    if (text_card.save)
      attach_file_to(text_card)
      flash[:notice] = "Text page updated"
    else
      flash[:notice] = "Error updating the text page"
    end
    
    redirect_to :controller => :firb_text_cards, :action => :index
  end
  
  private
  
  def attach_file_to(text_card)
    if(params[:firb_text_card][:file])
      
      xml_file = File.open(params[:firb_text_card][:file].path())
      doc = Nokogiri::XML(xml_file)
      schema  = Nokogiri::XML::RelaxNG(File.open('xslt/swicky_tei.rng'))
      error_string = "The XML source has not been attached to '#{text_card.title}' since it's not well formed. Hints:"+"<br><ul>"
      schema.validate(doc).each do |error|
        error_string += "<li>" + error.message + "</li>"
      end
      error_string += "</ul>"

      if (schema.valid?(doc)) 
        xml_data = TaliaCore::DataTypes::XmlData.new
        xml_data.create_from_data('data.xml', params[:firb_text_card][:file], :options => { :mime_type => 'text/xml' })
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