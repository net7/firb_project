require('hpricot')

class Admin::ImagesController < Admin::AdminSiteController

  hobo_model_controller

  auto_actions :all
  protect_from_forgery :only => [:create, :edit, :destroy]
  
  def index
    @images = Image.paginate(:page => params[:page], :prefetch_relations => true)
  end

  def show
    @image = Image.find(params[:id], :prefetch_relations => true)
  end

  def imtedit
    @image = Image.find(params[:id], :prefetch_relations => true)
  end


  # Will create a new Image, with some automatic zones automagically added
  def create
    # Check this before the real creation TODO: Bit of a hack
    Image.new.creatable_by?(current_user) or raise Hobo::PermissionDeniedError, "#{self.class.name}#create"
    img = Image.create_with_file(params[:image][:name], params[:image][:file])
    %w{auto_ana auto_img_1 auto_img_2 auto_text_1 auto_text_2 auto_capo}.each do |f|
      if (params[f] == "on") 
        img.add_zone!(I18n.t("image.auto_zone_names.#{f}"))
      end
    end
    if(img.save)
      flash[:notice] = "Image #{img.name} succesfully created"
    else
      flash[:notice] = "Error creating the image"
    end
    redirect_to :controller => :images, :action => :index
  end

  # Will remove an image from the db, with all of its zones
  def destroy
    hobo_destroy { redirect_to :controller => :images, :action => :index }
  end

  # Will add a zone to the Image with the given id
  def add_zone
    img = Image.find(params[:id])
    name = "auto_zone_#{rand Time.now.to_i}"
    img.add_zone!(name)
    if(img.save)
      flash[:notice] = "Added zone #{name} to image #{img.name}"
    else
      flash[:notice] = "Error in adding zone to the image #{img.name}"
    end
    redirect_to :controller => :images, :action => :index
  end
  
  # Will get some base64-ed xml and save the related image
  def flash_update
    Image.first.try.updatable_by?(current_user) or raise Hobo::PermissionDeniedError, "#{self.class.name}#update"
    b64 = params[:base64xml]
    ImageElement.save_from_xml(b64)
    expire_fragment('image_components')
    render :text => "OK"
  end
  
end
