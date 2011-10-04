class Boxview::IndiciController < Boxview::BaseController

  caches_page :show_grouped_iconclass, :fi_personaggi
  
  caches_page :show, :if => Proc.new {|c| c.request.url.split('/').last.in? ['anastaticas', 'pi_illustration_cards']}

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
    @search = SOLR.search(*vt_all_searchable_cards) do |s|
      s.dynamic :facets do |f|
        f.facet @category
        f.with @category
      end
    end
  end

  def show_vt_works_category
    @category = params[:category]
    @search = SOLR.search(*vt_all_searchable_cards) do |s|
      s.dynamic :facets do |f|
        f.facet @category
        f.with @category
      end
    end
  end

  def show_vt_glossary_term
    @glossary = params[:glossary]
    @search = SOLR.search(*vt_all_searchable_cards) do |s|
      s.dynamic :facets do |f|
        f.facet @glossary
        f.with @glossary
      end
    end
  end


  def show_vt_letters_by_name
    @category = params[:category]
    @name = params[:name]
    @search = SOLR.search(*vt_all_searchable_cards) do |s|
      s.dynamic :facets do |f|
        f.with @category, @name
      end
      s.order_by :boxview_title
    end
  end

  def show_vt_letters_by_work
    @category = params[:category]
    @work = params[:work]
    @search = SOLR.search(*vt_all_searchable_cards) do |s|
      s.dynamic :facets do |f|
        f.with @category, @work
      end
      s.order_by :boxview_title
    end
  end

  def show_vt_letters_by_glossary_term
    @glossary = params[:glossary]
    @term = params[:term]
    @search = SOLR.search(*vt_all_searchable_cards) do |s|
      s.dynamic :facets do |f|
        f.with @glossary, @term
      end
      s.order_by :boxview_title
    end
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

  def show_pi_memory_category
    @category = params[:category]
    @search = SOLR.search(SOLR::PiTextCard) do |s|
      s.dynamic :image_components do |f|
        f.facet @category
        f.with @category
      end
    end
  end


  def show_pi_name
    @category = params[:category]
    @search = SOLR.search(SOLR::PiTextCard) do |s|
      s.dynamic :facets do |f|
        f.facet @category
        f.with @category
      end
    end
  end

  def show_pi_name_by_category
    @category = params[:category]
    @name = params[:name]
    @search = SOLR.search(SOLR::PiTextCard) do |s|
      s.dynamic :facets do |f|
        f.with @category, @name
      end
#      s.order_by :boxview_title
    end
  end




  def show_pi_text_by_memory
    @category = params[:category]
    @name = params[:name]
    @search = SOLR.search(SOLR::PiTextCard) do |s|
      s.dynamic :image_components do |f|
        f.with @category, @name
      end
      s.order_by :boxview_title
    end
  end


  def fi_personaggi
    @personaggi = (FiCharacterCard.all + FiDeityCard.all).sort do |p1, p2|
        p1.name.to_s.strip <=> p2.name.to_s.strip
      end
  end

  def fi_character_quality_values
    @quality = params[:quality]
    @search = SOLR.search(SOLR::FiCharacterCard) do |s|
      s.facet @quality
      s.with @quality
    end
  end

  def fi_characters_by_quality_value
    @quality = params[:quality]
    @quality_value = params[:quality_value]
    @search = SOLR.search(SOLR::FiCharacterCard) do |s|
      s.with @quality, @quality_value
      s.order_by :boxview_title
    end
  end

  def fi_image_components
    @search = SOLR.search(*fi_all_searchable_cards) do |s|
      s.with     :image_components
      s.facet    :image_components
    end
  end

  def fi_cards_by_image_component
    @component = params[:component]
    @search = SOLR.search(*fi_all_searchable_cards) do |s|
      s.with :image_components, @component
      s.order_by :boxview_title
    end
  end

  def fi_bibliographies
    @search = SOLR.search(*fi_all_searchable_cards) do |s|
      s.facet :bibliography
      s.with  :bibliography
    end
  end

  def fi_cards_by_bibliography
    @bibliography = params[:bibliography]
    @search = SOLR.search(*fi_all_searchable_cards) do |s|
      s.with  :bibliography, @bibliography
      s.order_by :boxview_title
    end
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
    @glossary = "Lessico artistico"
    @search = SOLR.search(*vt_all_searchable_cards) do |s|
      s.dynamic :facets do |f|
        f.facet @glossary
        f.with  @glossary
      end
    end
  end

  def bg
    @collection_id = TaliaCore::Collection.find(:first).id
    @models = {:illustrazioni => 'Bg_Illustration_Card', :schede_testo => 'Bg_Text_Card', :anastatica => 'Anastatica', :iconclass => 'Iconclass_Term'}
  end

  private
    def fi_all_searchable_cards
      [SOLR::FiAnimalCard, SOLR::FiCharacterCard, SOLR::FiDeityCard, SOLR::FiParadeCartCard, SOLR::FiThroneCard, SOLR::FiVehicleCard, SOLR::FiEpisodeCard]
    end

    def vt_all_searchable_cards
      [SOLR::VtHandwrittenTextCard, SOLR::VtPrintedTextCard]
    end

    def pi_all_searchable_cards
      [SOLR::PiIllustratedMdCard, SOLR::PiIllustrationCard, SOLR::PiLetterIllustrationCard, SOLR::PiTextCard]
    end

  # end private
end
