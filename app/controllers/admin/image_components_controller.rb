class Admin::ImageComponentsController < Admin::AdminSiteController

  hobo_model_controller

  auto_actions :all, :except => :index

  def create
    @image_component = ImageComponent.create_component(params[:image_component])
    if(save_created!(@image_component))
      flash[:notice] = "Image component #{@image_component.name} succesfully created"
    else
      flash[:notice] = "Error creating the component"
    end
    if(request.xhr?)
      render :partial => 'admin/image_components/component_list', :object => @image_component.firb_card.image_components
    else
      redirect_to :controller => :image_components, :action => :index
    end
  end

  def destroy
    card = ImageComponent.find(params[:id]).firb_card
    hobo_destroy do 
      if(request.xhr?)
        render :partial => 'admin/image_components/component_list', :object => card.image_components
      else
        redirect_to :controller => :image_components, :action => :index
      end
    end
  end

end