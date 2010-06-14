module Admin::FirbTextCardHelper
  
  # Produces an hash to be passed to an input (select_for format)
  # with all of our Anastaticas
  def anastatiche_select
    foo = Anastatica.all.collect{|a| ["#{a.title}: #{a.page_position}", a.uri.to_s]}
    foo.sort
  end

  # Produces a title to be displayed, with page number and other infos
  def anastatica_pretty_title(ana)
    "#{ana.to_s}: with id #{ana.id}"
  end
  
  # Produces an hash to be passed to an input (select_for) format
  # with all of our ImageZones
  def image_zone_select_uri
    foo = ImageZone.all.collect do |a|
      parent = a.get_parent
      breadcrumbs = ""
      while(parent.class.to_s != "Image" && !parent.nil?)
        breadcrumbs = parent.name + " > " + breadcrumbs 
        parent = parent.get_parent
      end
      breadcrumbs = parent.name + " > " + breadcrumbs unless(parent.nil?)
      breadcrumbs += a.name
      
      [breadcrumbs, a.uri.to_s]
    end
    foo.sort
  end
  
  def bibliography_select
    BibliographyItem.all.collect { |b| [ "#{b.title}", b.uri.to_s ] }.sort
  end

  def iconclass_select
    IconclassTerm.all.collect { |ic| [ "#{ic.term}", ic.uri.to_s ] }.sort
  end

end