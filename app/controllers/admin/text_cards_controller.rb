require 'simplyx'
require 'nokogiri'

class Admin::TextCardsController < Admin::AdminSiteController

  def show_annotable
    record = TaliaCore::DataTypes::DataRecord.find(params[:id])
    @content = record.content_string
    render :template => 'admin/shared/show_annotable.dryml'
  end

end