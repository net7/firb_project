class Boxview::BgTextCardsController < Boxview::BaseController
  def show
    @resource = BgTextCard.find(params[:id], :prefetch_relations => true)
    @image    = @resource.image_zone.get_parent

    record = @resource.data_records.find_by_type_and_location('TaliaCore::DataTypes::XmlData', 'html2.html')
    @content = record.content_string

  end
end
