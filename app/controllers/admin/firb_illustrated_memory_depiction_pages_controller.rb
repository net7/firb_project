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

      logger.info "@@@@@@@@@@@@@@@@@@@@@@@ porca paletta #{params[:firb_illustrated_memory_depiction_page][:iconclass_term].inspect} ..... "

      params[:firb_illustrated_memory_depiction_page][:iconclass_term].each do |key, value|

        logger.info "@@@@@@@@@@@@@@@@@@@ On #{key} -> #{value}"
        iconclass_term = IconclassTerm.find(IconclassTerm.make_uri(value))
        logger.info "@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Found #{iconclass_term} from #{value} ??"
        if (!iconclass_term.nil?)
          logger.info "Adding #{iconclass_term} to #{@firb_illustrated_memory_depiction_page}"
          @firb_illustrated_memory_depiction_page.dct::subject << iconclass_term
        end
      end
    end
    
    redirect_to :controller => :firb_illustrated_memory_depiction_pages, :action => :index
  end



end