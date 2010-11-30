class Admin::PublishController < Admin::AdminSiteController

  def index
    render :text => "ACF"
  end
  
  def toggle
    @source = TaliaCore::ActiveSource.find(params[:id])
    @username = current_user.name + " ("+current_user.email_address.gsub("@","_AT_")+")"
    @source.toggle_published_by(@username)
    render :text => "ACF: #{@source.name}"
  end
  
end