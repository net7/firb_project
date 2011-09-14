class Admin::PublishController < Admin::AdminSiteController
  
  def toggle
    @source = TaliaCore::ActiveSource.find(params[:id])    
    @source.toggle_published_by(current_user.name)
    hobo_ajax_response if request.xhr?
   end

   def post_annotated
     html2 = params[:content] || ""
     annotations = params[:annotations] || ""

     @source = TaliaCore::ActiveSource.find(params[:id])
     if (@source) then
       @source.attach_html2("<div>#{html2}#{annotations}</div>")
       @source.save!

       id = @source.data_records.find_by_type_and_location('TaliaCore::DataTypes::XmlData', 'html2.html').id
       record = TaliaCore::DataTypes::DataRecord.find(id)
       @raw_content = record.content_string
       
       if (@source.is_a?(FiTextCard))

         v = Nokogiri::HTML.parse(@raw_content)
         # Handle consolidated annotations
         v.xpath(".//div[@class='consolidatedAnnotation']").each do |d|
           pred = d.xpath(".//div[@class='predicate']")[0]['about'];
           ca_class = d.xpath(".//span[@class='annotationClass']")[0].text

           # Has Note
           if (pred == 'http://purl.oclc.org/firb/swn_ontology#hasNote')
             n_name = d.xpath(".//div[@class='object']/span[@class='name']")[0].text
             n_content = d.xpath(".//div[@class='object']/span[@class='content']")[0].text
             @notes.push({:name => n_name, :content => n_content, :class => ca_class})
             d.remove
           end

           # Has Bibliography Item
           if (pred == 'http://purl.oclc.org/firb/swn_ontology#hasBibliographyItem')
             custom_bibl_url = d.xpath(".//div[@class='object']")[0]['about']
             custom_bibl = CustomBibliographyItem.find(custom_bibl_url, :prefetch_relations => true)
             bi = custom_bibl.bibliography_item
             n_name = "[#{bi.author} #{bi.date}]"
             # TODO: add more fields to this bibl item! ;)
             n_content = "\"#{bi.title}\": #{bi.author}, #{bi.pages}, #{bi.date}"
             @notes.push({:name => n_name, :content => n_content, :class => ca_class})
             d.remove
           end

         end # v.xpath().each 
         
       elsif (@source.is_a?(VtHandwrittenTextCard) || @source.is_a?(VtPrintedTextCard))
         
         v = Nokogiri::HTML.parse(@raw_content)
         # Handle consolidated annotations
         v.xpath(".//div[@class='consolidatedAnnotation']").each do |d|
           pred = d.xpath(".//div[@class='predicate']")[0]['about'];
           ca_class = d.xpath(".//span[@class='annotationClass']")[0].text

           # Has Note
           if (pred == 'http://purl.oclc.org/firb/swn_ontology#hasNote')
             n_name = d.xpath(".//div[@class='object']/span[@class='name']")[0].text
             n_content = d.xpath(".//div[@class='object']/span[@class='content']")[0].text
             @notes.push({:name => n_name, :content => n_content, :class => ca_class})
             d.remove
           end

           # Instance of
           if (pred == 'http://purl.oclc.org/firb/swn_ontology#instanceOf')
             di_id = d.xpath(".//div[@class='object']")[0]['about']
             di = DictionaryItem.find(di_id, :prefetch_relations => true)
             di_type = di.item_type.slice(41,100)
             @lex_art.push({:name => di.name, :fen_class => fen_class, :item_type => di_type, :class => ca_class})
             d.remove
           end

           # Has Bibliography Item
           if (pred == 'http://purl.oclc.org/firb/swn_ontology#hasBibliographyItem')
             custom_bibl_url = d.xpath(".//div[@class='object']")[0]['about']
             custom_bibl = CustomBibliographyItem.find(custom_bibl_url, :prefetch_relations => true)
             bi = custom_bibl.bibliography_item
             n_name = "[#{bi.author} #{bi.date}]"
             # TODO: add more fields to this bibl item! ;)
             n_content = "\"#{bi.title}\": #{bi.author}, #{bi.pages}, #{bi.date}"
             @notes.push({:name => n_name, :content => n_content, :class => ca_class})
             d.remove
           end

         end

       elsif (@source.is_a?(PiTextCard))
         
         v = Nokogiri::HTML.parse(@raw_content)
         # Handle consolidated annotations
         v.xpath(".//div[@class='consolidatedAnnotation']").each do |d|
           pred = d.xpath(".//div[@class='predicate']")[0]['about'];
           ca_class = d.xpath(".//span[@class='annotationClass']")[0].text

           # Has Note
           if (pred == 'http://purl.oclc.org/firb/swn_ontology#hasNote')
             n_name = d.xpath(".//div[@class='object']/span[@class='name']")[0].text
             n_content = d.xpath(".//div[@class='object']/span[@class='content']")[0].text
             @notes.push({:name => n_name, :content => n_content, :class => ca_class})
             d.remove
           end

           # Instance of
           if (pred == 'http://purl.oclc.org/firb/swn_ontology#instanceOf')
             di_id = d.xpath(".//div[@class='object']")[0]['about']
             di = DictionaryItem.find(di_id, :prefetch_relations => true)
             di_type = di.item_type.slice(41,100)
             @fenomeni.push({:name => di.name, :fen_class => fen_class, :item_type => di_type, :class => ca_class})
             d.remove
           end

           # Has image zone
           if (pred == "http://purl.oclc.org/firb/swn_ontology#hasImageZone")
             z_uri = d.xpath(".//div[@class='object']")[0]['about']
             z = ImageZone.find(z_uri, :prefetch_relations => true)
             z_name = d.xpath(".//div[@class='subject']/span[@class='label']")[0].text
             @fenomeni.push({:name => z_name, :fen_class => fen_class, :item_type => "Zone di immagine", :class => ca_class})
             d.remove
           end

           # Has memory depiction (both illustrated and non illustrated)
           if (pred == 'http://purl.oclc.org/firb/swn_ontology#hasMemoryDepiction')
             md_id = d.xpath(".//div[@class='object']")[0]['about']

               if PiNonIllustratedMdCard.exists?(md_id)
                 md = PiNonIllustratedMdCard.find(md_id, :prefetch_relations => true)   
               elsif PiIllustratedMdCard.exists?(md_id)
                 md = PiIllustratedMdCard.find(md_id, :prefetch_relations => true) 
               end

               @fenomeni.push({:name => md.short_description, :item_type => "Immagini di memoria", :class => ca_class})
               d.remove
           end

           d.remove
         end
         
         
       elsif (@source.is_a?(BgIllustrationCard))
       end
     end
     
     render :text => "ok"
   end
    
end
