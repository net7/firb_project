class SourceDataController < ApplicationController
  include TaliaCore::DataTypes
  # TODO: Needs upload_progress plugin - not so important atm
  # upload_status_for :create
  
  # GET /source_data/1
  def show
    send_record_data(TaliaCore::DataTypes::DataRecord.find(params[:id]))
  end
  
  def show_tloc
    @source_data = TaliaCore::DataTypes::DataRecord.find_by_type_and_location!(params[:type], params[:location])
    send_record_data(@source_data)
  end
  
  # Send the record to the browser
  def send_record_data(record)
    send_data record.content_string, :type => record.mime_type,
      :disposition => 'inline',
      :filename => record.location
  end
  
end
