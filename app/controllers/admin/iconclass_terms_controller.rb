class Admin::IconclassTermsController < Admin::AdminSiteController

  hobo_model_controller

  auto_actions :all
  
  def create
    @iconclass_term = IconclassTerm.create_term(params[:iconclass_term])
    if(@iconclass_term.save)
      flash[:notice] = "Iconclass term successfully created"
    else
      flash[:notice] = "Error creating term"
    end
    redirect_to :action => 'index'
  end
  
  def autocomplete
    # TODO: Implement
  end
  
end