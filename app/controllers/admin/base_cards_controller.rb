class Admin::BaseCardsController < Admin::AdminSiteController
  hobo_model_controller
  
  auto_actions :all

  before_filter :set_card_type, :uri_params

  include Admin::AnnotableController
  cache_sweeper :iconclass_sweeper


  def index
    @base_cards = @card_type.paginate(:page => params[:page], :prefetch_relations => true)
  end

  def new
    @base_card = @card_type.new
    @base_card.acting_user = current_user
  end

  def edit
    @base_card = BaseCard.find(params[:id], :prefetch_relations => true)
  end

  def show
    @base_card = BaseCard.find(params[:id], :prefetch_relations => true)
  end
  
  def destroy
    hobo_destroy { redirect_to :controller => :base_cards, :action => :index }
  end

  def create
    file = card_params.delete(:file)
    hobo_source_create(:params => card_params, :class_name => @card_type.name) do |card|
      foo = card.attach_xml_file(file) if (file && card.respond_to?(:attach_file))
      flash[:notice] += foo if (foo)
      redirect_to :action => :index
    end
  end
  
  def update
    file = card_params.delete(:file)
    hobo_source_update(:params => card_params) do |card|
      if (file)
        card.attach_xml_file(file)
        card.save!
      end
      redirect_to :action => :show, :id => card.id
    end
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
    params[@card_type_name.to_sym]
  end
  
  def default_type
    TaliaCore::CONFIG['base_card_types'] ? TaliaCore::CONFIG['base_card_types'].first : 'pi_illustrated_md_card'
  end
  
  # Creates the type class from the param passed to the action
  def set_card_type
    @card_type_name = (params[:type] || default_type)
    @full_type_name = @card_type_name
    @card_type = @full_type_name.classify.constantize
    raise(ArgumentError, "No valid card type") unless(@card_type <= BaseCard)
    @card_type
  end
  
  # changes some of the params to URI objects
  def uri_params
    return unless(card_params)
    # TODO: Hack for problem with autocomplete and "hidden" paramters
    card_params[:iconclass_terms] = card_params[:iconclass_terms].collect { |it| (it =~ /http:\/\//) ? it : IconclassTerm.make_uri(it) }if(card_params[:iconclass_terms])
  end

end
