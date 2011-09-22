class Boxview::IndiciController < Boxview::BaseController

  caches_page :show_grouped_iconclass


  def index
    @models = TaliaCore::CONFIG['shown_tabs'] + TaliaCore::CONFIG['base_card_types']
  end

  def show
    collection = TaliaCore::Collection.find_by_id(params[:collection])
    @items = params[:type].camelcase.singularize.constantize.menu_items_for(collection)
  end

  def show_vt_letters_by_date
    @items = VtLetter.menu_items_by_date
  end

  def show_vt_names_category
    @category = params[:category]
    @search = SOLR.search(SOLR::VtHandwrittenTextCard) do |s|
      s.dynamic :facets do |f|
        f.facet @category
      end
    end
  end

  def show_vt_letters_by_name
    @category = params[:category]
    @name = params[:name]
    @search = SOLR.search(SOLR::VtHandwrittenTextCard) do |s|
      s.dynamic :facets do |f|
        f.facet @name, @category
      end
      s.order_by :boxview_title
    end
  end

  def show_vt_letters_by_recipient
    @items = VtLetter.menu_items_by_recipient('foo')
  end

  def show_bg_illustration_by_owner
    @items = BgIllustrationCard.menu_items_for(CGI::unescape(params[:owner]).gsub('___thedot___','.'))
    render :show
  end

  def show_bg_owners
    collection = TaliaCore::Collection.find_by_id(params[:collection])
    @items = BgIllustrationCard.owners_for(collection)
  end

  def show_grouped_iconclass
    @collection = TaliaCore::Collection.first
    @groups = IconclassTerm.menu_groups    
  end

  def show_filtered_by_iconclass
    iconclass = IconclassTerm.find_by_id(params[:iconclass])
    params[:type] = 'iconclass_term'
    @items = IllustrationCard::find_anastaticas_by_iconclass(iconclass)
    render :show
  end

  def show_filtered
    collection = TaliaCore::Collection.find_by_id(params[:collection])
    @items = params[:type].camelcase.singularize.constantize.filtered_menu_items_for(collection, params[:subtype])
    render :show
  end

  def pi
    @collection_id = TaliaCore::Collection.find(:first).id
    @temp_models = [[@collection_id, 'Pi_Text_Card'], [@collection_id ,'Pi_Illustration_Card'], [@collection_id, 'Pi_Illustrated_Md_Card'], [@collection_id, 'Pi_Letter_Illustration_Card'], [@collection_id, 'Anastatica']]


    @models = {:schede_testo => 'Pi_Text_Card', :illustrazioni => 'Pi_Illustration_Card', :immagini_memoria => 'Pi_Illustrated_Md_Card', :anastatica => 'Anastatica', :iconclass => 'Iconclass_Term'}
    
  end

  def fi

    # the TaliaCore::Collection to which the anastatica are linked is the only one that
    # is neither a FiProcession nor a FiParade
    TaliaCore::Collection.all.each do |c|       
      if !c.is_a? FiProcession and !c.is_a? FiParade
        @collection_id = c.id
      end
    end
    
    @parade = FiParade.first
    @text_cards = FiTextCard.find(:all)
    @models = {:schede_carro => 'Fi_Parade_Cart_Cards', :carte => "fi_carte", :cortei => "fi_processions", :iconclass => "Iconclass_Term"}
  end

  def vt
    @collection_id = TaliaCore::Collection.find(:first).id #actually useless, needed by show method above
    @models = {:letter => 'Vt_Letter', :printed => 'Vt_Printed_Text_Card'}
  end

  def bg
    @collection_id = TaliaCore::Collection.find(:first).id
    @models = {:illustrazioni => 'Bg_Illustration_Card', :schede_testo => 'Bg_Text_Card', :anastatica => 'Anastatica', :iconclass => 'Iconclass_Term'}

  end
end
