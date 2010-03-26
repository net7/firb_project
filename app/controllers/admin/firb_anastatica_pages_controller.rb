class Admin::FirbAnastaticaPagesController < Admin::AdminSiteController

  hobo_model_controller

  auto_actions :all
  
  def create
    page = FirbAnastaticaPage.create_page(params[:firb_anastatica_page])
    if(page.save)
      flash[:notice] = "Image #{page.name} succesfully created"
    else
      flash[:notice] = "Error creating the page"
    end
    redirect_to :controller => :firb_anastatica_pages, :action => :index
  end
  
  
end