class Admin::TaliaCollectionsController < Admin::AdminSiteController
  
  hobo_model_controller
  
  auto_actions :all
  
  def reorder
    @talia_collection = TaliaCollection.find(N::URI.from_encoded(params[:id]))
    if(@talia_collection.with_acting_user(current_user) { @talia_collection.update_permitted? })
      order = params[:collection_order]
      element_hash = {}
      collection = @talia_collection.real_source
      collection.elements.each { |el| element_hash[el.id.to_s] = el }
      raise(ArgumentError, "Reorder must give the same number of elements than the original collection") unless(order.size == element_hash.size)
      collection.clear
      order.each do |ordered|
        element = element_hash[ordered]
        raise(ArgumentError, "Order contained an element that wasn't in the original collection") if(element.blank?)
        collection << element
      end
      collection.save!
    end
    render :text => 'Done'
  end
  
end