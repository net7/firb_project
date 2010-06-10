class FirbTextCard < TaliaCore::Source

  extend RandomId
  extend RdfProperties
  
  fields do
    uri :string
  end
  
  def name
    title || "#{I18n.t('firb_text_card.model_name')} #{self.id}"
  end
  
  # Creates a page initialazing it with a paraphrase and anastatica_page id
  def self.create_card(options)
    new_url =  (N::LOCAL + 'firb_text_card/' + random_id).to_s
    options[:uri] = new_url
    raise(ArgumentError, "Record already exists #{new_url}") if(TaliaCore::ActiveSource.exists?(new_url))
    self.new(options) # Check if it attaches :image_zone and :anastatica
  end

  def has_anastatica_page?
    !self.anastatica.blank?
  end

  def notes
    qry = ActiveRDF::Query.new(FirbNote).select(:note).distinct
    qry.where(:note, N::DCT.isPartOf, self)
    qry.execute
  end

  def notes_count
    notes.count
  end
  
  def has_notes?
    !new_record? && (notes.count > 0)
  end
  
  def attach_file(file)
    if(file)
      xml_string = file.read
      doc = Nokogiri::XML(xml_string)
      schema  = File.open('xslt/swicky_tei.rng') { |schemafile| Nokogiri::XML::RelaxNG(schemafile) }
      error_string = "The XML source has not been attached to '#{self.title}' since it's not well formed. Hints:"+"<br><ul>"
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
        options = {"source_uri" => self.uri.to_s }
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
  
end