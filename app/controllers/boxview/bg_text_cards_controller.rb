class Boxview::BgTextCardsController < Boxview::BaseController
  def show
    @resource = BgTextCard.find(params[:id], :prefetch_relations => true)
    @image    = @resource.anastatica.image_zone.get_parent if @resource.anastatica.present?

    record = @resource.data_records.find_by_type_and_location('TaliaCore::DataTypes::XmlData', 'html2.html')
    @content = record.content_string

  end
end
