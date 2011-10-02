class Boxview::BgIllustrationCardsController < Boxview::BaseController

caches_page :show

  def show
    @resource = BgIllustrationCard.find(params[:id], :prefetch_relations => true)
    @image    = @resource.image_zone.get_parent

    id = @resource.data_records.find_by_type_and_location('TaliaCore::DataTypes::XmlData', 'html2.html').id
    record = TaliaCore::DataTypes::DataRecord.find(id)
    @raw_content = record.content_string
    
    @notes = []
    @fenomeni = []
    @content = ''
    @zones = []
    zid_annclass = []
    
    v = Nokogiri::HTML.parse(@raw_content)
    # Handle consolidated annotations
    v.xpath(".//div[@class='consolidatedAnnotation']").each do |d|
      pred = d.xpath(".//div[@class='predicate']")[0]['about'];
      ca_class = d.xpath(".//span[@class='annotationClass']")[0].text

      # Has keyword
      if (pred == "http://purl.oclc.org/firb/swn_ontology#keywordForImageZone")
        z_uri = d.xpath(".//div[@class='object']")[0]['about']
        
        z = ImageZone.find(z_uri, :prefetch_relations => true)
        fen_class = Digest::MD5.hexdigest(pred)
        z_name = d.xpath(".//div[@class='subject']/span[@class='label']")[0].text
        @fenomeni.push({:name => z_name, :fen_class => fen_class, :item_type => "Zone di immagine", :class => ca_class, :zone_id => "#{z.id}"})
        v.xpath(".//span[contains(@class, '#{ca_class}')]").each{ |span| span['class'] += " #{fen_class}"  }
        
        zid_annclass.push({:zid =>"#{z.id}", :class => ca_class})
        @zones.push(z)
        d.remove
      end

    end

    # Sort fenomeni by type, name
    @fenomeni.sort! { |a,b| 
      if (a[:item_type].downcase == b[:item_type].downcase)
        a[:name].downcase <=> b[:name].downcase 
      else
        a[:item_type].downcase <=> b[:item_type].downcase 
      end
    } unless @fenomeni.nil?
    
    # The resulting modified HTML is the final content to display
    @content << v.to_s

  end
end
