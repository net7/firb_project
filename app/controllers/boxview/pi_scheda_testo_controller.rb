class Boxview::PiSchedaTestoController < Boxview::BaseController
  def show
    @resource = PiTextCard.find(params[:id], :prefetch_relations => true)
    id = @resource.data_records.find_by_type_and_location('TaliaCore::DataTypes::XmlData', 'html2.html').id
    record = TaliaCore::DataTypes::DataRecord.find(id)
    @content = record.content_string
  end
end
