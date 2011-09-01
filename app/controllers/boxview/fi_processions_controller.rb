class Boxview::FiProcessionsController < Boxview::BaseController

  def show
    procession = FiProcession.find_by_id params[:id]
    
    @items = procession.elements

    render 'boxview/indici/show'
  end
end
