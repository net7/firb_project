class Admin::BibliographyItemsController < Admin::AdminSiteController

  hobo_model_controller

  auto_actions :all
  
  def create
    @bibliography_item = BibliographyItem.create_item(params[:bibliography_item])
    if(@bibliography_item.save)
      flash[:notice] = "Bibliography item successefully created"
    else
      flash[:notice] = "Error creating item"
    end
    redirect_to :action => 'index'
  end
  
  def autocomplete
    raise(RuntimeError, "Not implemented")
  end
  
end