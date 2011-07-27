require 'action_view/helpers/tag_helper'

module ImtHelper
  include ActionView::Helpers::TagHelper

  # SEE: BoxViewHelper#image_xml
  def anastatica_image_xml(image, zones=[])
    image.anastatica_zones_xml(original_image_url(image), zones)
  end

  def imt_viewer(id, &block)
    yield(builder = ImtViewerBuilder.new(id))
    render :partial => '/boxview/shared/imageviewer', :locals => {:builder => builder}
  end
  alias_method :boxview_imt_viewer, :imt_viewer

  def imt_highlight(id, text, zone)
    content_tag :span, text, {
      :onmouseover => "getFlashObject('#{id}').setPolygonHighlighted(true, '#{zone}');",
      :onmouseout  => "getFlashObject('#{id}').setPolygonHighlighted(false, '#{zone}');",
      :id          => "image_zone_#{zone}",
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
