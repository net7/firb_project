class Admin::FirbTextPagesController < Admin::AdminSiteController

  hobo_model_controller

  auto_actions :all

  def create
    txt = FirbTextPage.new(N::LOCAL + 'firbtextpage/' + FirbImageElement.random_id)
    txt.parafrasi = params[:firb_text_page][:parafrasi]

    if(txt.save)
      flash[:notice] = "Text page succesfully created"
    else
      flash[:notice] = "Error creating the page"
    end
    redirect_to :controller => :firb_text_page, :action => :index
  end
  
end