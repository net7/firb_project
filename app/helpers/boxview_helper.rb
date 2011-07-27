require 'action_view/helpers/tag_helper'

module BoxviewHelper
  include ActionView::Helpers::TagHelper

  # SEE: BoxViewHelper#image_xml
  # DEPRECATED: use imt_image_b64 from imt_helper.rb
  def anastatica_image_xml(image, zones=[])
    image.anastatica_zones_xml(original_image_url(image), zones)
  end

  def boxview_link_code
    %[$(".boxview_link").live('click', function(e) {
          e.preventDefault();
          myBoxView.addBoxFromAjax(
            {qstring: $(this).attr('href'),
             title: $(this).data("title"), 
             verticalTitle: $(this).data("title"),
             resId: $(this).data("id"),
             type: $(this).data("type"),
             collapsed: false}
          );
        });]
  end

  ##
  # Parameters:
  #  url   - Url for the link
  #  text  - Text for the link
  #  title - Title for the new box
  #  id    - Resource id (used by boxview somehow)
  #  type  - Box type (used in styles)
  #  options - not used yet
  # Possible types:
  #   firb-memorie:
  #      box.index
  #      anastatic
  #      image
  #      notebooks
  #      transcription
  #      history
  #
  def boxview_link(url, text, title, id, type, options={})
    url_separator = url.include?('?') ? '&' : '?'
    %[<a class="boxview_link"
         href="#{url}#{url_separator}title=#{title}"
         data-title="#{title}"
         data-id="#{id}"
         data-type="#{type.to_s}">#{text}</a>]
  end

  # Options:
  #   * "class" html class for widget container
  def boxview_widget(title, options={}, &block)
    yield builder = WidgetBuilder.new
    klass = "widget"
    klass << " #{options[:class]}" if options[:class]

    content_tag :div, :class => klass do

      widget = content_tag(:div, :class => "widgetHeader toBeResized") do

        widget_header = content_tag :div, :class => "leftIcons" do
          content_tag :ul do 
            icons = content_tag :li, :class => "collapse" do
              content_tag :a, 'Collapse', :class => 'expanded', :href => '#',  :title => "Collapse"
            end
            icons << builder.render_left_icons
          end
        end

        widget_header << content_tag(:div, content_tag(:h4, title, :class => "widgetHeaderTitle"), :class => "title")

        widget_header << content_tag(:div, :class => "rightIcons") do
          content_tag :ul do 
            icons = builder.render_right_icons
            icons << content_tag(:li, :class => "drag") do
              content_tag :a, 'Drag', :href => '#', :title => "Drag"
            end
          end
        end
      end
      widget << builder.render_contents
    end
  end

  def boxview_widget_field(name, value, html_class='')
    return '' if value.blank?
    title   = content_tag :span, name, :class => "field_title expanded"
    content = content_tag :div, value, :class => "field_content expanded", :style => "display: block;"
    content_tag :div, title + content, :class => "widgetField #{html_class}"
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
      classes = ''
      @contents.each do |c|
        content << c[:content]
        classes << " #{render_classes(c[:classes])}"
      end
      # TODO: expanded should be set to true by default, if set to false
      # use the class collapsed
      content_tag(:div, content, :class => "widgetContent #{classes}")
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
end
