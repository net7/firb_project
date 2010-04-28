class Admin::FirbIllustratedMemoryDepictionCardsController < Admin::AdminSiteController

  hobo_model_controller

  auto_actions :all

  def create
    @firb_illustrated_memory_depiction_page = FirbIllustratedMemoryDepictionPage.create_page(params[:firb_illustrated_memory_depiction_page])
    if(@firb_illustrated_memory_depiction_page.save)
      flash[:notice] = "Illustrated memory depiction page succesfully created"
    else
      flash[:notice] = "Error creating the page"
    end

    if (params[:firb_illustrated_memory_depiction_page][:iconclass_term])
      FirbIllustrationPage.add_iconclass_terms(params[:firb_illustrated_memory_depiction_page][:iconclass_term], @firb_illustrated_memory_depiction_page)
    end
    
    @firb_illustrated_memory_depiction_page.save
    
    redirect_to :controller => :firb_illustrated_memory_depiction_pages, :action => :index
  end

  def remove_page
    p = FirbIllustratedMemoryDepictionPage.find(params[:id])
    if (p.remove)
      flash[:notice] = "Illustrated memory depiction page succesfully removed"
    else
      flash[:notice] = "Error removing the illustrated memory depiction page"
    end
    redirect_to :controller => :firb_illustrated_memory_depiction_pages
  end
  
  def update
    p = FirbIllustratedMemoryDepictionPage.find(params[:id])
    p.anastatica = FirbAnastaticaPage.find(params[:firb_illustrated_memory_depiction_page][:anastatica])
    p.image_zone = FirbImageZone.find(params[:firb_illustrated_memory_depiction_page][:image_zone])
    
    p.code = params[:firb_illustrated_memory_depiction_page][:code]
    p.collocation = params[:firb_illustrated_memory_depiction_page][:collocation]
    p.tecnique = params[:firb_illustrated_memory_depiction_page][:tecnique]
    p.measure = params[:firb_illustrated_memory_depiction_page][:measure]
    p.position = params[:firb_illustrated_memory_depiction_page][:position]
    p.descriptive_notes = params[:firb_illustrated_memory_depiction_page][:descriptive_notes]
    p.study_notes = params[:firb_illustrated_memory_depiction_page][:study_notes]
    p.description = params[:firb_illustrated_memory_depiction_page][:description]
    p.completed = params[:firb_illustrated_memory_depiction_page][:completed]
    
    if (params[:firb_illustrated_memory_depiction_page][:iconclass_term]) 
      FirbIllustrationPage.replace_iconclass_terms(params[:firb_illustrated_memory_depiction_page][:iconclass_term], p)
    end

    if (p.save!)
      flash[:notice] = "Illustrated memory depiction page updated"
    else
      flash[:notice] = "Error updating the illustrated memory depiction page"
    end
    redirect_to :controller => :firb_illustrated_memory_depiction_pages
  end
  

end