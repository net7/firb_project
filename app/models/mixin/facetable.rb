module Mixin::Facetable
  
  def facets
    build_facets unless @facets
    @facets
  end

  def facet_labels
    build_facets unless @facet_labels
    @facet_labels
  end

  def transcription_text
    build_facets unless @transcription_text
    @transcription_text
  end    

  protected
    def facets_allowed_predicates
      [N::FIRBSWN.hasNote.to_s, N::FIRBSWN.instanceOf.to_s]
    end

    def facets_predicate_allowed?(predicate)
      facets_allowed_predicates.include? predicate.to_s
    end

    def build_facets
      @facet_labels = {}
      @transcription_text = ""
      html = facets_transcription_xml
      return {} if html.nil? and components.nil?

      @facets = {}.tap do |facets|
        html.xpath(".//div[@class='consolidatedAnnotation']").each do |annotation|
          if facets_predicate_allowed?(predicate = annotation.xpath(".//div[@class='predicate']")[0]['about'])
            case predicate
              when N::FIRBSWN.hasNote.to_s
                key   = facets_annotation_get annotation, :object, :name
                value = facets_annotation_get annotation, :object, :content
                label = facets_annotation_get annotation, :subject, :label
              when N::FIRBSWN.instanceOf.to_s
                dictionary_value = DictionaryItem.find facets_annotation_get(annotation, :object), :prefetch_relations => true
                key   = dictionary_value.item_type.split('#').last
                value = dictionary_value.name
                label = facets_annotation_get annotation, :subject, :label
              when N::FIRBSWN.hasMemoryDepiction.to_s
                if(illustration = PiNonIllustratedMdCard.find(facets_annotation_get(:object), :prefetch_relations => true) rescue nil)
                  key   = "Immagini di memoria"
                  value = illustration.short_description
                  label = facets_annotation_get annotation, :subject, :label
                end
              when N::FIRBSWN.keywordForImageZone
                key   = "Zone di immagine"
                value = facets_annotation_get(annotation, :subject, :label)
                label = facets_annotation_get annotation, :subject, :label
              else key, value, label = nil
            end # case predicate
          end # if facets_predicate_allowed?
          annotation.remove
          if [key, value].all? {|x| x.present?}
            facets[key.to_s] << value.to_s unless (facets[key.to_s] ||= []).include? value.to_s
            @facet_labels[value.to_s] << label.to_s unless (@facet_labels[value.to_s] ||= []).include? label.to_s or label.to_s.blank?
          end
          @transcription_text = html.to_s

        end unless html.nil? # end html.xpath(".//div[@class='consolidatedAnnotation']").each

        (respond_to?(:image_components) ? image_components : []).each do |c|
          # FI doesn't have zone_type set, other may have. 
          key = c.zone_type.presence || "components"
          @facets[key.to_s] << c.name unless (@facets[key.to_s] ||= []).include? c.name
        end # end components.each
      end # {}.tap
    end # def build_facets

    def facets_transcription_xml
      raw_content = data_records.find_by_type_and_location('TaliaCore::DataTypes::XmlData', 'html2.html').content_string
      raw_content.present? ? Nokogiri::HTML.parse(raw_content) : nil
    rescue
      nil
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
