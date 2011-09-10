class Boxview::IndiciController < Boxview::BaseController

  def index
    @models = TaliaCore::CONFIG['shown_tabs'] + TaliaCore::CONFIG['base_card_types']
  end

  def show
    collection = TaliaCore::Collection.find_by_id(params[:collection])
    @items = params[:type].camelcase.singularize.constantize.menu_items_for(collection)
  end

  def show_grouped_iconclass
    @collection = TaliaCore::Collection.find_by_id(params[:collection])
    @groups = IconclassTerm.menu_groups_for(@collection)    
  end

  def show_filtered_by_iconclass
    iconclass = IconclassTerm.find_by_id(params[:iconclass])
    params[:type] = 'iconclass_term'
    @items = IllustrationCard.find_anastaticas_by_iconclass(iconclass)
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
        @collection = c
      end
    end


    
    @parade = FiParade.first
    @text_cards = FiTextCard.find(:all)
    @models = {:schede_carro => 'Fi_Parade_Cart_Cards', :carte => "fi_carte", :cortei => "fi_processions"}
  end

  def vt
    @temp = VtLetter.find :first
    @handwritten = VtHandwrittenTextCard.find :first
    @printed = VtPrintedTextCard.find :first
  end

  def bg
    @collection_id = TaliaCore::Collection.find(:first).id
    @temp_models = [[@collection_id, 'Bg_Illustration_Card'], [@collection_id ,'Bg_Text_Card'], [@collection_id, 'Anastatica']]
    @models = {:illustrazioni => 'Pi_Illustration_Card', :schede_testo => 'Pi_Text_Card', :anastatica => 'Anastatica'}

    # @temp = BgIllustrationCard.find_by_id 1311
    # @temp2 = BgIllustrationCard.find_by_id 1297
  end
end
