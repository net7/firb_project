class Boxview::VtHandwrittenTextCardsController < Boxview::BaseController

  caches_page :show


  def index
    @resource = VtLetter.find_by_id params[:vt_letter_id]
    @cards   = @resource.handwritten_cards
    @edition = @resource.handwritten_reference_edition
  end

  def show
    @resource = VtHandwrittenTextCard.find(params[:id], :prefetch_relations => true)
    @letter   = @resource.letter
    @printed = @letter.printed_cards

    @notes = []
    @fenomeni = []
    @content = ''
    @lex_art = []
    @raw_content = ''
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

        # Instance of
        if (pred == 'http://purl.oclc.org/firb/swn_ontology#instanceOf')
          di_id = d.xpath(".//div[@class='object']")[0]['about']
          di = DictionaryItem.find(di_id, :prefetch_relations => true)
          di_type = di.item_type.split('#').last
          fen_class = Digest::MD5.hexdigest(di.item_type)
          @fenomeni.push({:name => di.name, :fen_class => fen_class, :item_type => di_type, :class => ca_class})
          @lex_art.push({:name => di.name, :fen_class => fen_class, :item_type => di_type, :class => ca_class})
          v.xpath(".//span[contains(@class, '#{ca_class}')]").each{ |span| span['class'] += " #{fen_class}"  }
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
          v.xpath(".//span[contains(@class, '#{ca_class}')]").each{ |span| span['class'] += " #{fen_class}"  }
          d.remove
        end

        # Evolved in
        if (pred == 'http://purl.oclc.org/firb/swn_ontology#evolvedIn')
          n_this = d.xpath(".//div[@class='object']/span[@class='label']")[0].text
          n_that = d.xpath(".//div[@class='subject']/span[@class='label']")[0].text

          unless @printed.blank?
            related_link = "<br />in #{boxview_link_for_object(@printed.first, :url => vt_printed_text_card_url(@printed.first.id))}"
          end

          @notes.push({:name => n_this, :content => "diventa \"#{n_that}\"", :class => ca_class,
                        :apparatus => 'hw', :other_apparatus => 'pr', :related_link => related_link})
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

      # Sort lessico artistico by type, name
      @lex_art.sort! { |a,b| 
        if (a[:item_type].downcase == b[:item_type].downcase)
          a[:name].downcase <=> b[:name].downcase 
        else
          a[:item_type].downcase <=> b[:item_type].downcase 
        end
      } unless @lex_art.nil?
      
      # The resulting modified HTML is the final content to display
      @content << v.to_s

    end # if record

    @bibl = []
    @resource.bibliography_items.map do |item|
        @bibl.push render_to_string :partial => '/boxview/shared/custom_bibliography_item', :locals => {:custom => item, :item => item.bibliography_item}
    end

  rescue
  end # def show
end
