class Admin::FirbImageZonesController < Admin::AdminSiteController

  hobo_model_controller
  
  
  
  auto_actions :none

  # Removes a zone and all of its children
  def remove_zone
    zone = FirbImageZone.find(params[:id])
    if(zone.remove)
      flash[:notice] = "Removed zone #{zone.name}"
    else
      flash[:notice] = "Error in removing zone #{zone.name}"
    end
    redirect_to :controller => :firb_images, :action => :index
  end


  def add_zone
    zone = FirbImageZone.find(params[:id])
    name = "auto_zone_#{rand Time.now.to_i}"
    zone.add_zone!(name)
    if(zone.save)
      flash[:notice] = "Added zone #{name} to zone #{zone.name}"
    else
      flash[:notice] = "Error in adding zone to the zone #{zone.name}"
    end
    redirect_to :controller => :firb_images, :action => :index
  end

end