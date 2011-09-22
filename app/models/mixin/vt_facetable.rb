module Mixin::VtFacetable
  
  def facets
    @facets ||= build_facets
  end

  private
    def build_facets
      return {} unless is_public?
      html = transcription_xml
      return {} if html.nil?

      {}.tap do |facets|
        html.xpath(".//div[@class='consolidatedAnnotation']").each do |annotation|
          case annotation.xpath(".//div[@class='predicate']")[0]['about']
            when N::FIRBSWN.hasNote.to_s
              key   = annotation_get annotation, :object, :name
              value = annotation_get annotation, :object, :content
            when N::FIRBSWN.instanceOf.to_s
              dictionary_value = DictionaryItem.find annotation_get(annotation, :object), :prefetch_relations => true
              key   = dictionary_value.item_type.split('#').last
              value = dictionary_value.name
          end
          annotation.remove
          facets[key.to_s] << value.to_s if key.present? and value.present? and not (facets[key.to_s] ||= []).include?(value.to_s)
        end
      end
    end

    def transcription_xml
      raw_content = data_records.find_by_type_and_location('TaliaCore::DataTypes::XmlData', 'html2.html').content_string
      raw_content.present? ? Nokogiri::HTML.parse(raw_content) : nil
    rescue
      nil
    end

    def annotation_get(annotation, class1, class2=nil)
      if class2.present?
        annotation.xpath(".//div[@class='#{class1}']/span[@class='#{class2}']")[0].text
      else
        annotation.xpath(".//div[@class='#{class1}']")[0]['about']
      end
    rescue
      ""
    end
  # end private
end # module Mixin::VtFacetable
