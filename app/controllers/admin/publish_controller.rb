class Admin::PublishController < Admin::AdminSiteController
  
  def toggle
    @source = TaliaCore::ActiveSource.find(params[:id])    
    @source.toggle_published_by(current_user.name)
    hobo_ajax_response if request.xhr?
   end

   def post_annotated
     html2 = params[:content] || ""
     annotations = params[:annotations] || ""

     @source = TaliaCore::ActiveSource.find(params[:id])
     if (@source) then
       @source.attach_html2("<div>"+html2 + annotations+"</div>")
       @source.save!
     end

     render :text => "ok"
   end
    
end