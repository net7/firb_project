class Admin::FirbCardsController < Admin::AdminSiteController

  hobo_model_controller
  
  auto_actions :all

  before_filter :set_card_type, :uri_params
  
  def index
    @firb_cards = @card_type.paginate(:page => params[:page], :prefetch_relations => true)
  end

  def new
    @firb_card = @card_type.create_card
    @firb_card.acting_user = current_user
    @card_type = params[:type] || default_type
  end

  def edit
    @firb_card = FirbCard.find(params[:id], :prefetch_relations => true)
  end
  
  def destroy
    hobo_destroy { redirect_to :controller => :firb_cards, :action => :index }
  end

  def create
    @firb_card = @card_type.create_card(card_params)
    if(save_created!(@firb_card))
      flash[:notice] = "Card succesfully created"
    else
      flash[:notice] = "Error creating card"
    end
    redirect_to :action => :index
  end
  
  def update
    hobo_source_update(:params => card_params)
  end
  
  # Add the current card type to all links
  def default_url_options(options={})
    if(options[:type].to_s == 'false')
      options[:type] = nil
    else
      options[:type] ||= @card_type_name
    end
    options
  end
  
  private
  
  def card_params
    params[:"firb_#{@card_type_name}_card"]
  end
  
  def default_type
    'illustrated_memory_depiction'
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
    # TODO: Hack for problem with autocomplete and "hidden" paramters
    card_params[:iconclass_terms] = card_params[:iconclass_terms].collect { |it| (it =~ /http:\/\//) ? it : IconclassTerm.make_uri(it) }if(card_params[:iconclass_terms])
  end

end