class Admin::FirbImageZonesController < Admin::AdminSiteController

  hobo_model_controller

  auto_actions :all

  # Removes a zone along with all of its children
  def remove_zone
    logger.info "@@@@ Rimuovo dalla zona #{params[:id]}"
    
    zone = FirbImageZone.find(params[:id])
    qry = ActiveRDF::Query.new(FirbImageZone).select(:parent).distinct
    qry.where(:parent, N::TALIA.hasSubZone, zone)
    qry.where(:parent, N::RDF.type, N::TALIA.FirbImageZone)
    parent = qry.execute
    
    logger.info "---------------------------- #{parent}"
    
    if(parent.empty?)
      qry = ActiveRDF::Query.new(FirbImage).select(:parent).distinct
      qry.where(:parent, N::TALIA.hasSubZone, zone)
      qry.where(:parent, N::RDF.type, N::TALIA.FirbImage)
      parent = qry.execute
      logger.info "---------------------------- INSIDE? #{zone} #{parent}"
    end

    logger.info "---------------------------- #{parent}"
    parent = parent.first
    parent[N::TALIA.hasSubZone].remove(zone)

    if(parent.save)
      flash[:notice] = "Removed zone #{zone.name} from parent #{parent.name}"
    else
      flash[:notice] = "Error in removing zone #{zone.name}"
    end
    
    redirect_to :controller => :firb_images, :action => :index
  end


  def add_zone
    logger.info "@@@@ Aggiungo una zona alla zona #{params[:id]}"
    zone = FirbImageZone.find(params[:id])
    name = "auto_zone_#{Digest::SHA1.hexdigest Time.now.to_s}"
    zone.add_zone!(name)
    if(zone.save)
      flash[:notice] = "Added zone #{name} to zone #{zone.name}"
    else
      flash[:notice] = "Error in adding zone to the zone #{zone.name}"
    end
    redirect_to :controller => :firb_images, :action => :index
  end

end
