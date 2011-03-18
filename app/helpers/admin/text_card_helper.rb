# -*- coding: utf-8 -*-
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
    ImageZone.get_all_zones_array
  end
  
  def vt_handwritten_textcards_select
    VtHandwrittenTextCard.all.collect { |b| [ "#{b.title}", b.uri.to_s ] }.sort
  end

  def vt_printed_textcards_select
    VtPrintedTextCard.all.collect { |b| [ "#{b.title}", b.uri.to_s ] }.sort
  end
  
  def bibliography_select
    BibliographyItem.all.collect { |b| [ "#{b.ref_name} (#{b.author}: #{b.title})", b.uri.to_s ] }.sort
  end

  def custom_bibliography_select
    CustomBibliographyItem.all.collect { |b|
        name = (b.name.nil?) ? "" : b.name+": "
        ["#{name} (#{b.bibliography_item.author}: #{b.bibliography_item.title}) #{b.pages}", b.uri.to_s] 
    }.sort
  end

  def custom_bibliography_select_for(source)
    # TODO: this should expire sometime soon, when we deploy the new bibl-store
    cache = []
    source.bibliography_items.collect do |b|
      if (b.is_a?(BibliographyItem))
        ["[[ CANCELLAMI ]] #{b.ref_name} (#{b.author}: #{b.title})", b.uri.to_s] 
      elsif (b.is_a?(CustomBibliographyItem))
        name = (b.name.nil?) ? "" : b.name+": "
        bi_uri = b.bibliography_item.uri.to_s
        # TODO: this little cache trick gets an error "cant covert Integer to String", maybe
        # trying to index the cache array with a string? 
        #if (cache[bi_uri].nil?) 
        #  cache[bi_uri] = "(#{b.bibliography_item.author}: #{b.bibliography_item.title})"
        #end
        #["#{name} #{cache[bi_uri]} #{b.pages}", b.uri.to_s] 
        ["#{name} (#{b.bibliography_item.author}: #{b.bibliography_item.title}) #{b.pages}", b.uri.to_s] 
      end
    end 
  end

  def custom_edition_select_for(source)
    source.edition.collect do |b|
      if (b.is_a?(BibliographyItem))
        ["[[ CANCELLAMI ]] #{b.ref_name} (#{b.author}: #{b.title})", b.uri.to_s] 
      elsif (b.is_a?(CustomBibliographyItem))
        name = (b.name.nil?) ? "" : b.name+": "
        ["#{name} (#{b.bibliography_item.author}: #{b.bibliography_item.title}) #{b.pages}", b.uri.to_s] 
      end
    end 
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

  # Limits the dropdown menu to TaliaCore::Collection items
  def vt_letters_select
    VtLetter.all.collect! { |a| ["#{a.title}", a.uri.to_s]}.sort
  end

  def pi_text_card_select
    PiTextCard.all.collect! { |a| ["#{a.title}", a.uri.to_s]}.sort
  end

  # Placeholder for something more appropriate: something which gathers the real 
  # types from an ontology or some db thingie
  # TODO: FIXME: DEBUG: BUG: WHATEVER: the fi_character_card model have fixed fields for
  # these qualities ..
  def fi_character_qualities
    ["età","sesso","professione", "etnia"].collect{ |t| [t, t] }
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

  # Placeholder for something more appropriate: something which gathers the real 
  # types from an ontology or some db thingie
  def letter_component_types
    ["animale", "floreale", "vegetale", "umano"].collect{ |t| [t, t] }
  end

end
