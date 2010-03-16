class Admin::FirbImagesController < Admin::AdminSiteController
  
  hobo_model_controller
  
  auto_actions :all

  
  def create
    logger.info "@@@@ Arrivati #{params[:firb_image][:file]} con nome #{params[:firb_image][:name]}"
    @img = FirbImage.create(params[:firb_image][:name], params[:firb_image][:file])

    %w{auto_img_1 auto_img_2 auto_text_1 auto_text_2 auto_capo}.each do |f|
      logger.info "@@@ Param #{f} is #{params[f]}"
      if (params[f] == "on") 
        @img.add_zone(f, @img.name)
      end
    end
  end
  
  
end