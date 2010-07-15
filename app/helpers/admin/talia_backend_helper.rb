module Admin::TaliaBackendHelper
  
  def talia_type(this_parent, this_field)
    if(this_parent.is_a?(TaliaCore::ActiveSource) && this_field)
      this_parent.property_options_for(this_field)[:type] || String
    end
  end
  
  def source_name(src)
    src.respond_to?(:name) ? src.name : src.to_uri.local_name
  end
  
end