class Boxview::PiSchedaTestoController < Boxview::BaseController

  require 'nokogiri'

  def show
    @resource = PiTextCard.find(params[:id], :prefetch_relations => true)
    id = @resource.data_records.find_by_type_and_location('TaliaCore::DataTypes::XmlData', 'html2.html').id
    record = TaliaCore::DataTypes::DataRecord.find(id)
    @raw_content = record.content_string
    
    @content = ''
    @notes = []
    v = Nokogiri::HTML.parse(@raw_content)
    v.xpath(".//div[@class='consolidatedAnnotation']").each do |d|
      pred = d.xpath(".//div[@class='predicate']")[0]['about'];
      if (pred == 'http://purl.oclc.org/firb/swn_ontology#hasNote')
        n_class = d.xpath(".//span[@class='annotationClass']")[0].text
        n_name = d.xpath(".//div[@class='object']/span[@class='name']")[0].text
        n_content = d.xpath(".//div[@class='object']/span[@class='content']")[0].text
        @notes.push({:name => n_name, :content => n_content, :class => n_class})
      end
      #d.remove
    end

    # Replace a tagged <img> tag with an IMT container initalized with the 
    # given zone
    v.xpath(".//img[@class='source_img'][contains(@about, '/zones/')]").each do |d|
      @z = ImageZone.find(d['about'], :prefetch_relations => true)
      @image = @z.get_image_parent
      imt = render_to_string :partial => '/boxview/shared/imageviewer', 
               :locals => {:id => rand(Time.now.to_i), 
                           :base64 => @image.zones_xml(@image.uri, [@z.uri.to_s]),
                           :js_prefix => 'jsapi'}
      d.replace(Nokogiri::HTML.parse(imt).xpath(".//div"))
    end
    
    @content << v.to_s
    
  end
end
