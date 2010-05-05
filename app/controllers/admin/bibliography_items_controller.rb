class Admin::BibliographyItemsController < Admin::AdminSiteController

  hobo_model_controller

  auto_actions :all
  
  def create
    @bibliography_item = BibliographyItem.create_item(params[:bibliography_item])
    if(@bibliography_item.save)
      flash[:notice] = I18n.t("bibliography_items.succesfully_created")
    else
      flash[:notice] = I18n.t("bibliography_items.error_creating")
    end
    redirect_to :action => 'index'
  end
  
  def autocomplete
    raise(RuntimeError, "Not implemented")
  end
  
end