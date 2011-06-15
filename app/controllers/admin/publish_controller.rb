class Admin::PublishController < Admin::AdminSiteController
  
  def toggle
    @source = TaliaCore::ActiveSource.find(params[:id])

    # If it's not public and there's an html1 file, regenerate its html2 file
    unless (@source.is_public? || @source.data_records.find_by_type_and_location('TaliaCore::DataTypes::XmlData','html1.html').nil?)
      require 'net/http'
      jaxer_url = TaliaCore::CONFIG['jaxer_url']
      this_page_url = url_for(:controller => "/admin/base_cards", :action => :show_annotable, 
                      :id => @source.data_records.find_by_type_and_location('TaliaCore::DataTypes::XmlData','html1.html').id)
      resp = Net::HTTP.get(URI.parse(jaxer_url + "?uri=" + this_page_url))
      @source.attach_html2(resp)
    end
    
    @source.toggle_published_by(current_user.name)
    hobo_ajax_response if request.xhr?
   end

   def post_annotated
     html2 = params[:annotated_content] || ""
     annotations = params[:annotations] || ""

     @source = TaliaCore::ActiveSource.find(params[:id])
     if (@source) then       
       @source.attach_html2("<div class='a'>"+html2 + annotations+"</div>");
       @source.save!
     end

     render :text => "ok"
   end
    
end