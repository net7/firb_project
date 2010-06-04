require 'simplyx'
require 'nokogiri'

class Admin::FirbTextCardsController < Admin::AdminSiteController

  def show_annotable
    record = TaliaCore::DataTypes::DataRecord.find(params[:id])
    @content = record.content_string
  end

  private
  
  def attach_file_to(text_card, file)
    if (file)
      
      xml_file = File.open(file.path())
      doc = Nokogiri::XML(xml_file)
      schema  = Nokogiri::XML::RelaxNG(File.open('xslt/swicky_tei.rng'))
      error_string = "The XML source has not been attached to '#{text_card.title}' since it's not well formed. Hints:"+"<br><ul>"
      schema.validate(doc).each do |error|
        error_string += "<li>" + error.message + "</li>"
      end
      error_string += "</ul>"

      if (schema.valid?(doc)) 
        xml_data = TaliaCore::DataTypes::XmlData.new
        xml_data.create_from_data('data.xml', file, :options => { :mime_type => 'text/xml' })
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