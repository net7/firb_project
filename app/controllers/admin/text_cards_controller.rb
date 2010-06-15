require 'simplyx'
require 'nokogiri'

class Admin::TextCardsController < Admin::AdminSiteController

  def show_annotable
    record = TaliaCore::DataTypes::DataRecord.find(params[:id])
    @content = record.content_string
  end

end