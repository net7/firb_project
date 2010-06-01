class Admin::AdminSiteController < ApplicationController

  hobo_controller
  
  def save_created!(thing)
    thing.creatable_by?(current_user) or raise Hobo::PermissionDeniedError, "#{self.class.name}#create"
    thing.save
  end
  
  def hobo_source_update(options = {})
    options.to_options!
    thing = find_instance(options[:find_options] || {})
    thing.updatable_by?(current_user) or raise Hobo::PermissionDeniedError, "#{self.class.name}#update"
    thing.rewrite_attributes!(options[:params] || attribute_parameters)
    if(block_given?)
      yield(thing)
    else
      redirect_to :action => :show, :id => params[:id]
    end
  end
  
end