class Admin::FirbTextPagesController < Admin::AdminSiteController

  hobo_model_controller

  auto_actions :all

  def create
    txt = FirbTextPage.create_page(params[:firb_text_page][:parafrasi], params[:firb_text_page][:anastatica])

    if(txt.save)
      flash[:notice] = "Text page succesfully created"
    else
      flash[:notice] = "Error creating the page"
    end
    redirect_to :controller => :firb_text_pages, :action => :index
  end
  
end