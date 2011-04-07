class Admin::DictionaryItemsController < Admin::AdminSiteController

  hobo_model_controller
  auto_actions :all

def index

    conditions = { :prefetch_relations => true, :include => :data_records }
    if (params[:type])
      conditions.merge!(:find_through => [N::TALIA.dictionary_item_type, params[:type]])
    end

    @dictionary_items = DictionaryItem.paginate(conditions.merge(:page => params[:page]))
  end

end