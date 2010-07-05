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
  
  # Lists all the possible Bg- sources (illustration cards and text cards)
  def bg_related_sources_select
    foo = BgIllustrationCard.all.collect { |ill| ["Illustrazione: #{ill.name}", ill.uri.to_s]}
    foo = foo + BgTextCard.all.collect { |t| ["Scheda testo: #{t.name}", t.uri.to_s]}
    foo.sort
  end
  
  # Limits the dropdown menu to TaliaCore::Collection items
  def bg_books_select 
    foo = TaliaCollection.all
    foo.reject! do |t| 
        real_class = (t.is_a?(TaliaCollection)) ? t.real_source.class : t.class 
        real_class != TaliaCore::Collection
    end
    foo.collect! { |a| ["#{a.title}", a.uri.to_s]}
    foo.sort
  end

  # Placeholder for something more appropriate: something which gathers the real 
  # types from an ontology or some db thingie
  def pi_component_types
    ["luoghi", "numeri", "lettere dell'alfabeto", "persone", "oggetti"].collect{ |t| [t, t] }
  end

  # Placeholder for something more appropriate: something which gathers the real 
  # types from an ontology or some db thingie
  def pi_memory_depiction_types
    ["luoghi", "numeri", "lettere dell'alfabeto", "persone", "oggetti", "scene"].collect{ |t| [t, t] }
  end

end