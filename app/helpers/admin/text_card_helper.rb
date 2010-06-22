module Admin::TextCardHelper
  
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
  
  # Limits the dropdown menu to TaliaCore::Collection items
  def bg_books_select 
    foo = TaliaCollection.all
    foo.reject! do |t| 
        real_class = (t.is_a?(TaliaCollection)) ? t.real_source.class : t.class 
        real_class != TaliaCore::Collection
    end
    foo.collect! { |a| ["#{a.title}: #{a.class.name}", a.uri.to_s]}
    foo.sort
  end

end