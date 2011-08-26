class Boxview::FiProcessionsController < Boxview::BaseController
  include ImtHelper
  include BoxviewHelper

  def show
    procession = FiProcession.find_by_id params[:id]
    
    @items = procession.elements

    render 'boxview/indici/show'
  end
end
