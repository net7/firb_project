require 'action_view/helpers/tag_helper'
require "base64"

module ImtHelper
  include ActionView::Helpers::TagHelper
  include AdminHelper

  ##
  #
  # Uses AdminHelper.original_image_url.
  def imt_image_b64(image, zones=[])
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.dctl_ext_init{
      xml.img{
        xml.a(:r => image.id.to_s, :s => image.uri.to_s, :l => image.name, :u => original_image_url(image))
      }
      xml.xml{
      unless zones.size.zero?
        # First zone is assumed as the one of main interest, where the image will focus (zoom to).
        outer = zones.delete zones.first
# TODO: remove next line
#        outer_coordinates = outer.coordinates.nil? ? "0:0:0:1:1:0:1:1" : outer.coordinates
        xml.a(:r => outer.id.to_s, :s => outer.uri.to_s, :l =>outer.name, :t =>"#{image.uri}@#{outer.coordinates}"){
          zones.each do |z|
            xml.a(:r => z.id.to_s, :s => z.uri.to_s, :l=> z.name, :t => "#{image.uri}@#{z.coordinates}")
          end
        }
      end
      }
      xml.cb(:u => nil, :p => "base64xml")
    }
    Base64.encode64(xml.target!).gsub(/\s/, '')
  end

  def imt_viewer(id, &block)
    yield(builder = ImtViewerBuilder.new(id))
    render :partial => '/boxview/shared/imageviewer', :locals => {:builder => builder}
  end
  alias_method :boxview_imt_viewer, :imt_viewer

  def imt_highlight_id(imt_id, zone_id)
    "#{imt_id}_image_zone_#{zone_id}"
  end

  def imt_jquery_highlight_selector(imt_id)
    "##{imt_highlight_id(imt_id, "")}"
  end

  def imt_highlight(id, text, zone)
    content_tag :span, text, {
      :onmouseover => "getFlashObject('#{id}').setPolygonHighlighted(true, '#{zone}');",
      :onmouseout  => "getFlashObject('#{id}').setPolygonHighlighted(false, '#{zone}');",
      :id          => imt_highlight_id(id, zone),
      :class       => "single-zone"
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
