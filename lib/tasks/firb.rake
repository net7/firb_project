require 'talia_util/rake_tasks'

	
namespace :firb do
    desc 'recreate HTML1 files for XML transcriptions file for all sources with available XML files'
    task :recreate_html1 => 'talia_core:init' do	  
        sources = TaliaCore::Source.find(:all)
	sources.each do |source| 
	
	data_xml = source.data_records.find_by_type_and_location('TaliaCore::DataTypes::XmlData', 'data.xml')

	puts "found in #{source.uri.to_s} one data_xml processing it" unless data_xml.nil?

	unless data_xml.nil?
	  xml_data = TaliaCore::DataTypes::XmlData.new	
	  xml_data.create_from_data('data.xml', data_xml.all_text, :options => { :mime_type => 'text/xml' })
	  source.data_records.destroy_all
          source.data_records << xml_data
          options = {"source_uri" => source.uri.to_s}
          xsl_file = 'xslt/HTML1.xsl'
          xml_file = xml_data.full_filename
          html1 = Simplyx::XsltProcessor::perform_transformation(xsl_file, xml_file, options)
          html1_data = TaliaCore::DataTypes::XmlData.new
          html1_data.create_from_data('html1.html', html1, :options => { :mime_type => 'text/xml' })
          source.data_records << html1_data
          source.save!
    	end


     #  xml_data = TaliaCore::DataTypes::XmlData.new



     #   xml_data.create_from_data('data.xml', xml_string, :options => { :mime_type => 'text/xml' })
     #   self.data_records.destroy_all
     #   self.data_records << xml_data
     #   # here we prepare the HTML1 version of the uploaded file, the one to be used by swickynotes
     #   # to add semantic notes to the text.
     #   # the XSLT needs the source_uri parameter to fill some THCTag with it, we pass it in the 
     #   # "options" hash
     #   options = {"source_uri" => self.uri.to_s}
     #   xsl_file = 'xslt/HTML1.xsl'
     #   xml_file = xml_data.full_filename
     #   html1 = Simplyx::XsltProcessor::perform_transformation(xsl_file, xml_file, options)
     #   html1_data = TaliaCore::DataTypes::XmlData.new
     #   html1_data.create_from_data('html1.html', html1, :options => { :mime_type => 'text/xml' })
     #   self.data_records << html1_data
     #   self.save!
     #   return false

	end
   end    
  
   desc "Recreates the thumbnails for all the Images"
   task :recreate_thumbnails => 'talia_core:init' do	  
   
     prog = ProgressBar.new('Recreating', Image.count)

     Image.all.each do |image|
       data_records = image.data_records
       image_data = data_records.find_by_type('TaliaCore::DataTypes::ImageData').
       iip_data = data_records.find_by_type('TaliaCore::DataTypes::IipData')
#       iip_data.write_file_after_save(TaliaCore::DataTypes::FileStore::DataPath.new(image_data.file_path))
       TaliaUtil::ImageConversions::create_thumb(TaliaCore::DataTypes::FileStore::DataPath.new(image_data.file_path), TaliaCore::DataTypes::FileStore::DataPath.new(iip_data.file_path))

       prog.inc      
     end

   end



end