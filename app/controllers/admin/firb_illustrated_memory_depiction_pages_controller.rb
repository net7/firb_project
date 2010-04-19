class Admin::FirbIllustratedMemoryDepictionPagesController < Admin::AdminSiteController

  hobo_model_controller

  auto_actions :all

  def create
    @firb_illustrated_memory_depiction_page = FirbIllustratedMemoryDepictionPage.create_page(params[:firb_illustrated_memory_depiction_page])
    if(@firb_illustrated_memory_depiction_page.save)
      flash[:notice] = "Illustrated image depiction succesfully created"
    else
      flash[:notice] = "Error creating the page"
    end

    if (params[:firb_illustrated_memory_depiction_page][:iconclass_term])
      params[:firb_illustrated_memory_depiction_page][:iconclass_term].each do |key, value|
        iconclass_term = IconclassTerm.find(IconclassTerm.make_uri(value))
        if (!iconclass_term.nil?)
          @firb_illustrated_memory_depiction_page.dct::subject << iconclass_term
        end
      end
    end
    
    @firb_illustrated_memory_depiction_page.save
    
    redirect_to :controller => :firb_illustrated_memory_depiction_pages, :action => :index
  end



end