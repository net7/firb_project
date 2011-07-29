class Boxview::IndiciController < Boxview::BaseController

  def index
    @models = TaliaCore::CONFIG['shown_tabs'] + TaliaCore::CONFIG['base_card_types']
  end

  def show
    collection = TaliaCore::Collection.find_by_id(params[:collection])
    @items = params[:type].camelcase.singularize.constantize.menu_items_for(collection)
  end

  def pi
    collection_id = TaliaCore::Collection.find(:first).id
    @models = [[collection_id, 'Pi_Text_Card'], [collection_id ,'Pi_Illustration_Card'], [collection_id, 'Pi_Illustrated_Md_Card'], [collection_id, 'Pi_Letter_Illustration_Card'], [collection_id, 'Anastatica']]
  end

end
