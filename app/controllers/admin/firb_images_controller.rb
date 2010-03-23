class Admin::FirbImagesController < Admin::AdminSiteController

  hobo_model_controller

  auto_actions :all

  # Overriden default hobo edit action, to include IMT editor
  def edit
    @firb_image = FirbImage.find(params[:id])
    # TODO: Replace me!
    #@base64 = @firb_image.zones_xml('http://192.168.7.5:3000/stub.jpg')
    #@base64 = @firb_image.zones_xml(original_image_url(@firb_image))
  end

  # Will create a new FirbImage, with some automatic zones automagically added
  def create
    img = FirbImage.create_with_file(params[:firb_image][:name], params[:firb_image][:file])
    %w{auto_img_1 auto_img_2 auto_text_1 auto_text_2 auto_capo}.each do |f|
      if (params[f] == "on") 
        img.add_zone!(f)
      end
    end
    if(img.save)
      flash[:notice] = "Image #{img.name} succesfully created"
    else
      flash[:notice] = "Error creating the image"
    end
    redirect_to :controller => :firb_images, :action => :index
  end

  # Will remove an image from the db, with all of its zones
  def remove_image
    img = FirbImage.find(params[:id])
    name = img.name
    if (img.remove)
      flash[:notice] = "Image #{name} removed with all of its zones"
    else
      flash[:noteice] = "Error removing the image"
    end
    redirect_to :controller => :firb_images, :action => :index
  end

  # Will add a zone to the FirbImage with the given id
  def add_zone
    img = FirbImage.find(params[:id])
    name = "auto_zone_#{rand Time.now.to_i}"
    img.add_zone!(name)
    if(img.save)
      flash[:notice] = "Added zone #{name} to image #{img.name}"
    else
      flash[:notice] = "Error in adding zone to the image #{img.name}"
    end
    redirect_to :controller => :firb_images, :action => :index
  end
  
end