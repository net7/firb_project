require 'action_view/helpers/tag_helper'
require "base64"

module ImtHelper
  include ActionView::Helpers::TagHelper
  include AdminHelper

  ##
  # Defines a set of javascrip/jQuery functions that can be used in conjunction with the imt helpers.
  #
  def imt_jquery_helper_functions
    <<-eos
    <script language="javascript">
      // Helper functions for Image Mapper Tool.

      // Given a jQuery selector, this function will locate the first element identified
      // by the selector is a link. If found, the function will "click" it.
      function imtActivateFirstWithLink(elements) {
        if(elements) {
          elements.each(function(i, el) {
            if($(el).parent().is('a')) {
              $(el).parent().click();return false;
            }
          });
        }
        return false;
      }
    </script>
    eos
  end

  ##
  #
  # Uses AdminHelper.original_image_url.
  def imt_image_b64(image, zones=[])
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.dctl_ext_init{
      xml.img{
        xml.a(:r => image.id.to_s, :s => image.uri.to_s, :l => image.name, :u => original_image_url(image))
      }
      unless zones.size.zero?
        # First zone is assumed as the one of main interest, where the image will focus (zoom to).
        outer = zones.delete zones.first
        outer_coordinates = outer.coordinates
        outer_coordinates = "0:0:1:0:1:1:0:1" unless outer_coordinates.nil?
        xml.xml{
          xml.a(:r => outer.id.to_s, :s => outer.uri.to_s, :l =>outer.name, :t =>"#{image.uri}@#{outer.coordinates}"){
            zones.each do |z|
              xml.a(:r => z.id.to_s, :s => z.uri.to_s, :l=> z.name, :t => "#{image.uri}@#{z.coordinates}") unless z.nil? or z.coordinates.nil?
            end
          } 
        }
      end
      xml.cb(:u => nil, :p => "base64xml")
    }
    Base64.encode64(xml.target!).gsub(/\s/, '')
  end

  def imt_viewer(id, &block)
    yield(builder = ImtViewerBuilder.new(id))
    render :partial => '/boxview/shared/imageviewer', :locals => {:builder => builder}
  end
  alias_method :boxview_imt_viewer, :imt_viewer

  # NOTE deprecated: do not use ids to identify zone-related elements, univocity cannot be guaranteed.
  def imt_highlight_id(imt_id, zone_id)
    "#{imt_id}_image_zone_#{zone_id}"
  end

  def imt_highlight_class(imt_id, zone_id)
    "#{imt_id}_image_zone_#{zone_id}"
  end

  def imt_jquery_highlight_selector(imt_id)
    ".#{imt_highlight_class(imt_id, "")}"
  end

  def imt_highlight(id, text, zone)
    content_tag :span, text, {
      :onmouseover => "if(getFlashObject('#{id}')) getFlashObject('#{id}').setPolygonHighlighted(true, '#{zone}');",
      :onmouseout  => "if(getFlashObject('#{id}')) getFlashObject('#{id}').setPolygonHighlighted(false, '#{zone}');",
      :class       => "#{imt_highlight_class(id, zone)} single-zone"
    }
  end
  alias_method :boxview_imt_highlight, :imt_highlight

  class ImtViewerBuilder
    attr_accessor :id, :base64, :js_prefix, :init, :click, :over, :out

    def initialize(id)
      @id = id
    end

    def js_prefix
      @js_prefix || @id
    end
  end
end
