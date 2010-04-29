module Admin::FirbTextPageHelper
  
  # Produces an hash to be passed to an input (select_for format)
  # with all of our FirbAnastaticaPages
  def anastatiche_select
    foo = FirbAnastaticaPage.all.collect{|a| ["#{a.title}: #{a.uri.to_name_s}", a.uri.to_s]}
    foo.sort
  end

  # Produces a title to be displayed, with page number and other infos
  def anastatica_pretty_title(ana)
    "#{ana.to_s}: with id #{ana.id}"
  end
  
  # Produces an hash to be passed to an input (select_for) format
  # with all of our FirbImageZones
  def image_zone_select
    foo = FirbImageZone.all.collect{ |a|
      
      parent = a.get_parent
      breadcrumbs = ""
      loop do
        breadcrumbs = parent.name + " > " + breadcrumbs 
        if (parent.class.to_s == "FirbImage")
          break
        else
          parent = parent.get_parent
        end
      end
      breadcrumbs += a.name
      
      ["#{breadcrumbs}: #{a.id}", a.id]
    }
    foo.sort
  end

end