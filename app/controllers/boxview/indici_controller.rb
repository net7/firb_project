class Boxview::IndiciController < Boxview::BaseController

  def index
    @models = TaliaCore::CONFIG['shown_tabs'] + TaliaCore::CONFIG['base_card_types']
  end

  def show
    @items = params[:type].camelcase.singularize.constantize.find(:all, :prefetch_relations => true)
    @items = @items.select { |i| i.is_public? }
  end

end
