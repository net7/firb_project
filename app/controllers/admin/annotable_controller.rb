module Admin::AnnotableController


  def show_annotable
    record = TaliaCore::DataTypes::DataRecord.find(params[:id])
    # http link to the additional sources available for this record
    @source_uri = record.source.uri.to_s
    @source_url = url_for(:action => "related_topic", :topic => @source_uri, :controller => "swicky_notebooks/context/")
    @content = record.content_string
    render :template => 'admin/shared/show_annotable.dryml'
  end

  def show_preview
    
    record = TaliaCore::DataTypes::DataRecord.find(params[:id])
    @content = record.content_string
    render :template => 'admin/shared/show_preview.dryml'
  end

end