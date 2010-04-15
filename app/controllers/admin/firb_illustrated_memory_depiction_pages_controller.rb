class Admin::FirbIllustratedMemoryDepictionPagesController < Admin::AdminSiteController

  hobo_model_controller

  auto_actions :all

  def create
    @firb_illustrated_memory_depiction_page = FirbIllustratedMemoryDepictionPage.create_page(params[:firb_illustrated_memory_depiction_page])
    if(@firb_illustrated_memory_depiction_page.save)
      flash[:notice] = "Illustrated image depiction #{@firb_illustrated_memory_depiction_page} succesfully created"
    else
      flash[:notice] = "Error creating the page"
    end
    redirect_to :controller => :firb_illustrated_memory_depiction_pages, :action => :index
  end



end