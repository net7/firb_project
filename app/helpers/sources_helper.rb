module SourcesHelper

  # Link to the index
  def index_link
    link_to 'index', :action => 'index'
  end

  # About parameter with the uri of the current source (if the is a current source,
  # blank string otherwise)
  def source_about
    @source ? (' about ="' << @source.uri.to_s << '"') : ''
  end

  # Checks if the current filter points to the given type
  def current_filter?(ctype)
    (ctype.to_name_s('+') == params[:filter])
  end

  # Links to filter for the given type
  def filter_link_for(ctype)
    link_to ctype.to_name_s, :action => 'index', :filter => ctype.to_name_s('+')
  end

  # Gets the title for a source
  def title_for(source)
    (source[N::DCNS.title].first || source[N::RDF.label].first || N::URI.new(source.uri).local_name.titleize)
  end


  # If the element is a resource or an uri-like element, create a link to that element (if it's just a string, it
  # is just passed through). 
  #
  # If the element is in the "local" namespace, the helper will automatically create a correct URI, even if the
  # current app doesn't run on the "local" domain. Otherwise it will use the URI itself for the link URI.
  def semantic_target(element)
    if(element.respond_to?(:uri))
      uri = element.to_uri
      if(uri.local?)
        link_to(uri.to_name_s, :controller => 'sources', :action => 'dispatch', :dispatch_uri => uri.local_name)
      else
        link_to(uri.to_name_s, uri.to_s)
      end
    else
      element
    end
  end
  
  
  
  def type_images(types)
    @type_map ||= { 
      N::TALIA.Source => 'source',
      N::FOAF.Group => 'group',
      N::LUCCADOM.epoch => 'period',
      N::LUCCADOM.building => 'building',
      N::LUCCADOM.museum => 'image',
      N::LUCCADOM.epoch => 'period',
      N::LUCCADOM.document => 'document',
      N::LUCCADOM.artwork => 'image',
      N::LUCCADOM.place => 'map',
      N::LUCCADOM.city => 'map',
      N::FOAF.Person => 'person',
      N::LUCCADOM.church => 'building'
    }
    result = ''
    types.each do |t|
      image = @type_map[t] || 'source'
      name = t.local_name.titleize
      result << link_to(image_tag("demo/#{image}.png", :alt => name, :title => name),
        :action => 'index', :filter => t.to_name_s('+')
      )
    end
    result
  end
  
  def data_icons(data_records)
    result = ''
    data_records.each do |rec|
      link_data = data_record_options(rec)
      result << link_to(
        image_tag("demo/#{link_data.first}.png", :alt => rec.location, :title => rec.location),
        { :controller => 'source_data',
          :action => 'show',
          :id => rec.id },
        link_data.last
      )
    end
    
    result
  end

  private

  def data_record_options(record)
    if(record.mime.include?('image/'))
      ['image', {:class => 'cbox_image'}]
    elsif(record.mime.include?('text/'))
      ['text', {:class =>'cbox_inline' }]
    elsif(record.mime == 'application/xml')
      ['text', {:class => 'cbox_inline'}]
    else
      ['gear', {}]
    end
  end

end
