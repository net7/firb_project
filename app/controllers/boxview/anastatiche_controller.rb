class Boxview::AnastaticheController < Boxview::BaseController
  def show
    @resource = Anastatica.find_by_id params[:id]
    @image = @resource.image_zone.get_image_parent

    qry = ActiveRDF::Query.new(BgTextCard).select(:x).distinct
    qry.where(:x, N::DCT.isPartOf, @resource.uri)
    qry.where(:x, N::RDF.type, N::TALIA.BgTextCard)
    @bg_text_cards = qry.execute

  end
end
