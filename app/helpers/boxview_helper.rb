require 'action_view/helpers/tag_helper'

module BoxviewHelper
  include ActionView::Helpers::TagHelper

  # SEE: BoxViewHelper#image_xml
  def anastatica_image_xml(image, zones=[])
    image.anastatica_zones_xml(original_image_url(image), zones)
  end

  # Options:
  #   * draggable
  def boxview_widget(title, type=nil, options={}, &block)
    yield builder = WidgetBuilder.new

    content = content_tag :div, :class => "widget widget_draggable" do
      content_tag(:div, :class => "widgetHeader toBeResized") do
        temp = content_tag :div, :class => "leftIcons" do
          content_tag :ul do 
            temp2 = content_tag :li, :class => "collapse" do
              content_tag :a, 'Collapse', :class => 'expanded', :href => '#',  :title => "Collapse"
            end
            temp2 << builder.render_left_icons
          end
        end

        temp << content_tag(:div, content_tag(:h4, title, :class => "widgetHeaderTitle"), :class => "title")

        temp << content_tag(:div, :class => "rightIcons") do
          content_tag :ul do 
            temp2 = builder.render_right_icons
            temp2 << content_tag(:li, :class => "drag") do
              content_tag :a, 'Drag', :href => '#', :title => "Drag"
            end
          end
        end
      end
    end

    content << builder.render_contents
  end

  def boxview_imt_viewer(id, &block)
    yield(builder = ImtViewerBuilder.new(id))
    render :partial => '/boxview/shared/imageviewer', :locals => {:builder => builder}
  end

  class WidgetBuilder
    include ActionView::Helpers::TagHelper

    def initialize
      @contents    = []
      @right_icons = []
      @left_icons  = []
    end

    # options:
    #   [:expanded]
    def content(content, classes=[:expanded])
      @contents << {:content => content, :classes => classes}
    end

    # options
    #   {:class => 'asd'} # For the enclosing <li>
    def right_icons(content, options={})
      @right_icons << {:content => content, :options => options}
    end

    def left_icons(content, options={})
      @left_icons << {:content => content, :options => options}
    end

    def render_contents
      content = ''
      @contents.each do |c|
        content << content_tag(:div, c[:content], :class => "widgetContent #{render_classes(c[:classes])}")
      end
      content
    end

    def render_left_icons
      render_icons @left_icons
    end

    def render_right_icons
      render_icons @right_icons
    end

    def render_icons(icons)
      result = ''
      icons.each do |i|
        result << content_tag(:li, i[:content], i[:options])
      end
      result
    end

    def render_classes(classes)
      classes.map {|o| o.to_s}.join ' '
    end
  end

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
