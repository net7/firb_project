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
    @bibliography_item = BibliographyItem.create_item(params[:bibliography_item])
    if(@bibliography_item.save)
      flash[:notice] = I18n.t("bibliography_items.succesfully_created")
    else
      flash[:notice] = I18n.t("bibliography_items.error_creating")
    end
    redirect_to :action => 'index'
  end
  
  def update
    @bibliography_item = BibliographyItem.find(params[:id], :prefetch_relations => true)
    if(@bibliography_item.update_attributes(params[:bibliography_item]))
      flash[:notice] = I18n.t("bibliography_items.successfully_update")
    else
      flash[:notice] = I18n.t("bibliography_items.error_updating")
    end
    redirect_to :action => 'index'
  end
  
  def autocomplete
    raise(RuntimeError, "Not implemented")
  end
  
end