module Admin::TaliaSourcesHelper
  
  def all_collections
    collections = TaliaCollection.find(:all)
    exclude = FiParade.all + FiProcession.all
    exclude.collect! { |c| c.uri }
    collections.reject { |col| exclude.include?(col.uri) }
  end
  
end