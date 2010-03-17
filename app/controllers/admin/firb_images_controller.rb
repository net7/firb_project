class Admin::FirbImagesController < Admin::AdminSiteController
  
  hobo_model_controller
  
  auto_actions :all, :except => :remove_zone

  # Will create a new FirbImage, with some automatic zones automagically added
  def create
    logger.info "@@@@ Arrivati #{params[:firb_image][:file]} con nome #{params[:firb_image][:name]}"
    @img = FirbImage.create(params[:firb_image][:name], params[:firb_image][:file])

    %w{auto_img_1 auto_img_2 auto_text_1 auto_text_2 auto_capo}.each do |f|
      logger.info "@@@ Param #{f} is #{params[f]}"
      if (params[f] == "on") 
        @img.add_zone(f)
      end
    end
  end

  # Will remove a zone from the db
  def remove_zone 
    logger.info "@@@@ Rimuovo la firb image #{params[:id]}"
  end
  
  # Will add a zone to the FirbImage with the given id
  def add_zone
    logger.info "@@@@ Aggiungo la firb image #{params[:id]}"
  end
  
  
end