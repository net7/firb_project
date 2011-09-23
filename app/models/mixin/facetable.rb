module Mixin::Facetable
  
  def facets
    @facets ||= build_facets
  end

  def transcription_text
    html = facets_transcription_xml
    return "" if html.nil?
    html.xpath(".//div[@class='consolidatedAnnotation']").each {|annotation| annotation.remove}
    html.to_s
  end

  protected
    def facets_allowed_predicates
      [N::FIRBSWN.hasNote.to_s, N::FIRBSWN.instanceOf.to_s]
    end

    def facets_predicate_allowed?(predicate)
      facets_allowed_predicates.include? predicate.to_s
    end

    def build_facets
      html = facets_transcription_xml
      return {} if html.nil?

      {}.tap do |facets|
        html.xpath(".//div[@class='consolidatedAnnotation']").each do |annotation|
          if facets_predicate_allowed?(predicate = annotation.xpath(".//div[@class='predicate']")[0]['about'])
            case predicate
              when N::FIRBSWN.hasNote.to_s
                key   = facets_annotation_get annotation, :object, :name
                value = facets_annotation_get annotation, :object, :content
              when N::FIRBSWN.instanceOf.to_s
                dictionary_value = DictionaryItem.find facets_annotation_get(annotation, :object), :prefetch_relations => true
                key   = dictionary_value.item_type.split('#').last
                value = dictionary_value.name
              when N::FIRBSWN.hasMemoryDepiction.to_s
                if(illustration = PiNonIllustratedMdCard.find(facets_annotation_get(:object), :prefetch_relations => true) rescue nil)
                  key   = "Immagini di memoria"
                  value = illustration.short_description
                end
              when N::FIRBSWN.keywordForImageZone
                key   = "Zone di immagine"
                value = facets_annotation_get(annotation, :subject, :label)
              else key, value = nil
            end # case predicate
          end # if facets_predicate_allowed?
          annotation.remove
          facets[key.to_s] << value.to_s if key.present? and value.present? and not (facets[key.to_s] ||= []).include?(value.to_s)
        end # html.xpath(".//div[@class='consolidatedAnnotation']").each
      end # {}.tap do |facets|
    end # def build_facets

    def facets_transcription_xml
      @facets_transcription_xml ||= begin
                                      raw_content = data_records.find_by_type_and_location('TaliaCore::DataTypes::XmlData', 'html2.html').content_string
                                      raw_content.present? ? Nokogiri::HTML.parse(raw_content) : nil
                                    rescue
                                      nil
                                    end
    end

    def facets_annotation_get(annotation, class1, class2=nil)
      if class2.present?
        annotation.xpath(".//div[@class='#{class1}']/span[@class='#{class2}']")[0].text
      else
        annotation.xpath(".//div[@class='#{class1}']")[0]['about']
      end
    rescue
      ""
    end
  # end protected
end # module Mixin::VtFacetable
