class Boxview::IndiciController < Boxview::BaseController

  def index
    @models = TaliaCore::CONFIG['shown_tabs'] + TaliaCore::CONFIG['base_card_types']
  end

  def show
    @items = params[:type].camelcase.singularize.constantize.find(:all, :prefetch_relations => true)
    @items = @items.select { |i| i.is_public? }
  end

  def pi
    @models = %w{Pi_Text_Card Pi_Illustration_Card Pi_Illustrated_Md_Card Pi_Letter_Illustration_Card Anastatica}
  end

end
