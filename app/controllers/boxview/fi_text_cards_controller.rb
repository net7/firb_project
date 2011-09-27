class Boxview::FiTextCardsController < Boxview::BaseController
  def show
    @notes = []
    @fenomeni = []
    @content = ''

    @resource = FiTextCard.find(params[:id], :prefetch_relations => true)
    if record = @resource.data_records.find_by_type_and_location('TaliaCore::DataTypes::XmlData', 'html2.html')
      @raw_content = record.content_string
    
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
          fen_class = Digest::MD5.hexdigest('bibliography_item')
          @fenomeni.push({:name => n_name, :fen_class => fen_class, :item_type => 'Elementi Bibliografici', :class => ca_class})
          @notes.push({:name => n_name, :content => n_content, :class => ca_class})
          v.xpath(".//span[contains(@class, '#{ca_class}')]").each{ |span| span['class'] += " #{fen_class}" }
          d.remove
        end
      end # v.xpath(".//div[@class='consolidatedAnnotation']").each

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
    end # if record

    @bibl = []
    @resource.bibliography_items.map do |item|
      @bibl.push render_to_string :partial => '/boxview/shared/custom_bibliography_item', :locals => {:custom => item, :item => item.bibliography_item}
    end

  end

  def boxview_data
    { :controller => 'boxview/fi_text_cards',
      :title => "TEXT CARD",
      :description => "TEXT CARD",
      :res_id => "fi_text_card_#{self.id}", 
      :box_type => nil,
      :thumb => nil
    }
  end
end
