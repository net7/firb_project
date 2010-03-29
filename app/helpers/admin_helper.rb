require 'base64'

module AdminHelper
  def admin_toolbar
    widget(:toolbar, :buttons => [ 
        ["Home", {:controller => 'source', :action => 'show', :id => 'Lucca'}], 
        ["Admin", {:action => 'index'} ],
        ["Sources", {:controller => 'admin/sources' }],
        ["Users", { :controller => 'admin/users'} ],
        ["Print Page", "javascript:print();"]
      ] )
  end
  
  # Returns the title for the whole page. This returns the value
  # set in the controller, or a default value
  def page_title
    @page_title || TaliaCore::SITE_NAME
  end
  
  # Show each <tt>flash</tt> status (<tt>:notice</tt>, <tt>:error</tt>) only if it's present.
  def show_flash
    [:notice, :error].collect do |status|
      %(<div id="#{status}">#{flash[status]}</div>) unless flash[status].nil?
    end
  end
  
  # Defines the pages that are visible in the menu
  def active_pages
    %w(users background sources) # translations not working at the moment, templates not ready for generic use
  end
  
  def original_image_url(image)
    url_for_data_record(image.original_image)
  end
  
  def thumb_url(image)
    url_for_data_record(image.iip_record)
  end
  
  def thumb_xml(image, zone_list=nil)
    image.zones_xml(thumb_url(image), zone_list)
  end
  
  def image_xml(image)
    image.zones_xml(original_image_url(image))
  end

  def url_for_data_record(record)
    if(record)
      url_for :controller => '/source_data', :action => 'show', :id => record.id
    else
      ''
    end
  end
  
  
  
end

