module FileAttached 

  # Will return false if everything is ok, else an error string with some hints on the XML
  def attach_xml_file(file)
    if(file)
      xml_string = file.read
      doc = Nokogiri::XML(xml_string)
      schema  = File.open('xslt/swicky_tei.rng') { |schemafile| Nokogiri::XML::RelaxNG(schemafile) }
      error_string = "The XML source has not been attached since it's not well formed. Hints:"+"<br><ul>"
      schema.validate(doc).each do |error|
        error_string += "<li>" + error.message + "</li>"
      end
      error_string += "</ul>"

      if (schema.valid?(doc)) 
        xml_data = TaliaCore::DataTypes::XmlData.new
        xml_data.create_from_data('data.xml', xml_string, :options => { :mime_type => 'text/xml' })
        self.data_records.destroy_all
        self.data_records << xml_data
        # here we prepare the HTML1 version of the uploaded file, the one to be used by swickynotes
        # to add semantic notes to the text.
        # the XSLT needs the source_uri parameter to fill some THCTag with it, we pass it in the 
        # "options" hash
        options = {"source_uri" => self.to_uri.local_name}
        xsl_file = 'xslt/HTML1.xsl'
        xml_file = xml_data.full_filename
        html1 = Simplyx::XsltProcessor::perform_transformation(xsl_file, xml_file, options)
        html1_data = TaliaCore::DataTypes::XmlData.new
        html1_data.create_from_data('html1.html', html1, :options => { :mime_type => 'text/xml' })
        self.data_records << html1_data
        self.save!
        return false
      else
        return error_string
      end
    end
  end

  def attach_pdf_file(file)
    self.attach_files(:url => file.path, :options => {:mime_type => file.content_type.to_s, :location => file.original_filename})
  end

end