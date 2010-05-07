class Admin::TaliaSourcesController < Admin::AdminSiteController
  
  hobo_model_controller

  auto_actions :all, :except => :index
  
  def show
    @talia_source = find_instance
    @real_source = @talia_source.real_source
    @property_names = @real_source.direct_predicates
    @properties = {}
    @property_names.each do |pred|
      @properties[pred.to_s] = @real_source[pred]
    end
  end
  
  # Connect the current source to the collection passed by the
  # request
  def assign_collection
    source, collection = get_source_and_collection
    collection.updatable_by?(current_user) || raise(Hobo::PermissionDeniedError, "#{self.class.name}#assign_collection")
    collection << source
    collection.save!
  end
  
  # Remove the current source from the collection given by the
  # request
  def remove_collection
    source, collection = get_source_and_collection
    collection.updatable_by?(current_user) || raise(Hobo::PermissionDeniedError, "#{self.class.name}#assign_collection")
    collection.delete(source)
    collection.save!
  end
  
  private
  
  # Set up source and collection and related class vars for the
  # assign/remove_collection methods
  def get_source_and_collection
    source_uri = N::URI.from_encoded(params[:source])
    collection_uri = N::URI.from_encoded(params[:collection])
    source = TaliaCore::ActiveSource.find(source_uri)
    collection = TaliaCore::Collection.find(collection_uri)
    @source_id = params[:source]
    @source = TaliaSource.find(source.id)
    if(real= @source.real_source.class.include?(Hobo::Model))
      @source = @source.real_source
    end
    [ source, collection ]
  end
  
end