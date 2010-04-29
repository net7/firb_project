class Admin::FirbCardsController < Admin::AdminSiteController

  hobo_model_controller

  auto_actions :all

  before_filter :set_card_type, :uri_params
  
  def index
    @firb_cards = @card_type.paginate(:page => params[:page])
  end

  def new
    @firb_card = @card_type.create_card
    @firb_card.acting_user = current_user
    @card_type = params[:type] || default_type
  end

  def create
    @firb_card = @card_type.create_card(card_params)
    if(@firb_card.save)
      flash[:notice] = "Card succesfully created"
    else
      flash[:notice] = "Error creating card"
    end
    
    redirect_to :action => :index
  end

  def remove_page
    card = FirbCard.find(params[:id])
    if (card.remove)
      flash[:notice] = "Card succesfully removed"
    else
      flash[:notice] = "Error removing the card"
    end
    redirect_to :action => :index
  end
  
  def update
    @firb_card = FirbCard.find(params[:id])
    @firb_card.update_attributes!(card_params)

    redirect_to :action => :index
  end
  
  # Add the current card type to all links
  def default_url_options(options={})
    options[:type] ||= @card_type_name
    options
  end
  
  private
  
  def card_params
    params[:"firb_#{@card_type_name}_card"]
  end
  
  def default_type
    'non_illustrated_memory_depiction'
  end
  
  # Creates the type class from the param passed to the action
  def set_card_type
    @card_type_name = (params[:type] || default_type)
    @full_type_name = "firb_#{@card_type_name}_card"
    @card_type = @full_type_name.classify.constantize
    raise(ArgumentError, "No valid card type") unless(@card_type <= FirbCard)
    @card_type
  end
  
  # changes some of the params to URI objects
  def uri_params
    return unless(card_params)
    card_params[:anastatica] = card_params[:anastatica].to_uri if(card_params[:anastatica].is_a?(String))
  end

end