class Boxview::PiSchedaTestoController < Boxview::BaseController

  require 'nokogiri'

  def show
    @resource = PiTextCard.find(params[:id], :prefetch_relations => true)
    id = @resource.data_records.find_by_type_and_location('TaliaCore::DataTypes::XmlData', 'html2.html').id
    record = TaliaCore::DataTypes::DataRecord.find(id)
    @raw_content = record.content_string
    
    @content = ''
    @notes = []
    @fenomeni = []
    imts = {}
    zones = []
    zid_annclass = []

    v = Nokogiri::HTML.parse(@raw_content)
    
    # Replace a tagged <img> with an IMT container initalized with the 
    # given zones
    v.xpath(".//img[@class='source_img'][contains(@about, '/zones/')]").each do |d|
      z = ImageZone.find(d['about'], :prefetch_relations => true)
      
      capo = !PiLetterIllustrationCard.find(:all, :find_through => [N::DCT.isFormatOf, z.uri]).empty?
      imts[z.uri.to_s] = {'zones' => [z], 'node' => d, 'capolettera' => capo}
      
      # Find and remove the consolidated annotation with this image zone.. otherwise
      # it's not a tagged <img>, hence it's a zone tagged in the text
      v.xpath(".//div[@class='consolidatedAnnotation'][contains(@about, '#{d['about']}')]").each do |ca|
        sub_lab = ca.xpath(".//div[@class='subject']/span[@class='label']")[0].text
        if (sub_lab.include? '[image: illustration.jpg]')
          ca.remove
        else
          zones.push(z)
        end
      end
      
    end
    
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
        fen_class = Digest::MD5.hexdigest(di.item_type)
        @fenomeni.push({:name => di.name, :fen_class => fen_class, :item_type => di_type, :class => ca_class})
        v.xpath(".//span[contains(@class, '#{ca_class}')]").each{ |span| span['class'] += " #{fen_class}"  }
        d.remove
      end

      # Has image zone
      if (pred == "http://purl.oclc.org/firb/swn_ontology#hasImageZone")
        z_uri = d.xpath(".//div[@class='object']")[0]['about']
        
        z = ImageZone.find(z_uri, :prefetch_relations => true)
        fen_class = Digest::MD5.hexdigest(pred)
        z_name = d.xpath(".//div[@class='subject']/span[@class='label']")[0].text
        @fenomeni.push({:name => z_name, :fen_class => fen_class, :item_type => "Zone di immagine", :class => ca_class})
        v.xpath(".//span[contains(@class, '#{ca_class}')]").each{ |span| span['class'] += " #{fen_class}"  }
        
        zid_annclass.push({:zid =>"#{z.id}", :class => ca_class})
        zones.push(z)
        d.remove
      end

      # Has memory depiction (both illustrated and non illustrated)
      if (pred == 'http://purl.oclc.org/firb/swn_ontology#hasMemoryDepiction')
        md_id = d.xpath(".//div[@class='object']")[0]['about']

        begin
          md = PiIllustratedMdCard.find(md_id, :prefetch_relations => true)
        rescue
          md = PiNonIllustratedMdCard.find(md_id, :prefetch_relations => true)
        else
          # DEBUG: just one class for both ill and non-ill MDs? 
          fen_class = Digest::MD5.hexdigest(pred)
          @fenomeni.push({:name => md.short_description, :fen_class => fen_class, :item_type => "Immagini di memoria", :class => ca_class})
          v.xpath(".//span[contains(@class, '#{ca_class}')]").each{ |span| span['class'] += " #{fen_class}"  }
          d.remove
        end
          
      end
      d.remove
    end

    imts.each do |bounding_zone, values| 
      
      # The image real URL is in its .static_path, if there's one
      z = ImageZone.find(bounding_zone, :prefetch_relations => true)
      image = z.get_image_parent
      if (image.original_image.static_path.nil?)
        image_url = url_for :controller => '/source_data', :action => 'show', :id => image.original_image.id, :only_path => false
      else
        image_url = image.original_image.static_path
      end

      # If it's a capolettera, dont include any extra zone, otherwise include
      # all of the consolidated image zones. Use a different icon for image/letter
      if (values['capolettera'])
        imt_zones = [z]
        imt = "<div><a title='Mostra capolettera' class='transcription_letter_icon'>SHOW IMAGE</a>"
      else
        imt_zones = [z].concat(zones)
        imt = "<div><a title='Mostra immagine' class='transcription_image_icon'>SHOW IMAGE</a>"

        # Map zone image ids to consolidated annotation classes (IMT use the id, the 
        # annotated text uses the ca_classes): use a global array using this
        # zone's id as name
        zid_map = "zidc_#{z.id} = []; "
        zid_annclass.each do |foo| 
          zid_map += "zidc_#{z.id}[#{foo[:zid]}] = '#{foo[:class]}';"
          zid_map << %[
            $('.transcription_text .#{foo[:class]}').
                mouseover(function(){ 
                    if ($(this).hasClass('highlighted') && (typeof(getFlashObject('imt_image_#{z.id}').setPolygonHighlighted) === 'function')) 
                        getFlashObject('imt_image_#{z.id}').setPolygonHighlighted(true, '#{foo[:zid]}'); 
                }).mouseout(function(){ 
                    if ($(this).hasClass('highlighted') && (typeof(getFlashObject('imt_image_#{z.id}').setPolygonHighlighted) === 'function')) 
                        getFlashObject('imt_image_#{z.id}').setPolygonHighlighted(false, '#{foo[:zid]}'); 
                });
            ]
        end
        imt += "<script>#{zid_map}</script>";
      end
      
      imt += "<span class='transcription_img_wrapper hidden'>"
      imt += render_to_string :partial => '/boxview/shared/imageviewer', 
               :locals => {:id => "imt_image_#{z.id}", 
                           :base64 => image.anastatica_zones_xml(image_url, imt_zones),
                           :js_prefix => "t_img_#{z.id}",
                           :init => "jsapi_initializeIMW(id)",
                           :over => "$('.'+zidc_#{z.id}[ki]).addClass('zone_highlighted')",
                           :out => "$('.'+zidc_#{z.id}[ki]).removeClass('zone_highlighted')"
                }
      imt += '<a title="Apri in un bel box" class="transcription_open_icon">APRI IN BOX</a>'
      imt += '<a title="Chiudi" class="transcription_close_icon">CHIUDI</a>'
      imt += "</span></div>"

      values['node'].replace(Nokogiri::HTML.parse(imt).xpath(".//div")[0])
    end

    # Sort fenomeni by type, name
    @fenomeni.sort! { |a,b| 
      if (a[:item_type].downcase == b[:item_type].downcase)
        a[:name].downcase <=> b[:name].downcase 
      else
        a[:item_type].downcase <=> b[:item_type].downcase 
      end
    }
    
    # The resulting modified HTML is the final content to display
    @content << v.to_s
    
    # Illustrated and non-illustrated memory depictions
    @non_ill_md = @resource.non_illustrated_memory_depictions
    @ill_md = PiIllustratedMdCard.find(:all, :find_through => [N::TALIA.attachedText, @resource.uri])
    
  end
end
