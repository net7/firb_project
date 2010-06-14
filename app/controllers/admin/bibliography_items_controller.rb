class Admin::BibliographyItemsController < Admin::AdminSiteController

  hobo_model_controller

  auto_actions :all
  
  def index
    @bibliography_items = BibliographyItem.paginate(:page => params[:page], :prefetch_relations => true)
  end
  
  def edit
    @bibliography_item = BibliographyItem.find(params[:id], :prefetch_relations => true)
  end
  
  def create
    @bibliography_item = BibliographyItem.new(params[:bibliography_item])
    if(save_created(@bibliography_item))
      flash[:notice] = I18n.t("bibliography_items.succesfully_created")
    else
      flash[:notice] = I18n.t("bibliography_items.error_creating")
    end
    redirect_to :action => 'index'
  end
  
  def update
    hobo_source_update(:find_options => { :prefetch_relations => true }) { redirect_to :action => :index }
  end
  
  def autocomplete
    raise(RuntimeError, "Not implemented")
  end
  
end