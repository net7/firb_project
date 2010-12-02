class Admin::PublishController < Admin::AdminSiteController
  
  def toggle
    @source = TaliaCore::ActiveSource.find(params[:id])
    unless (@source.data_records.find_by_type_and_location('TaliaCore::DataTypes::XmlData','html1.html').nil?)
      require 'net/http'
      jaxer_url = TaliaCore::CONFIG['jaxer_url']
      this_page_url = url_for(:controller => "/admin/base_cards", :action => :show_annotable, :id => @source.data_records.find_by_type_and_location('TaliaCore::DataTypes::XmlData','html1.html').id)

      puts "@@@@@@@@@@@@@@@@@@ " + " Jaxer: "+jaxer_url.to_s + " >> " + this_page_url

      #args = {'html1' => render_to_string something somewhere someway somewhat }
      #resp, data = Net::HTTP.post_form(jaxer_url, args)
      puts URI.parse(jaxer_url + "?uri=" + this_page_url).to_s

      resp = Net::HTTP.get(URI.parse(jaxer_url + "?uri=" + this_page_url))
      puts "@@@@@@@@@@@@@@@@@@ " + this_page_url + "\n\n >> " + resp.to_s
    end
    @source.toggle_published_by(current_user.name)
    hobo_ajax_response if request.xhr?
   end
  
end