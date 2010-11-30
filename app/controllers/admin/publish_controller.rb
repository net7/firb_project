class Admin::PublishController < Admin::AdminSiteController
  
  def toggle
    @source = TaliaCore::ActiveSource.find(params[:id])
    @source.toggle_published_by(current_user.name)
    hobo_ajax_response if request.xhr?
   end
  
end