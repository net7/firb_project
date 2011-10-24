class CustomBibliographyItem < TaliaCore::Source
  hobo_model # Don't put anything above this
  include StandardPermissions
  extend RdfProperties
  
  autofill_uri :force => true
  
  rdf_property :name, N::TALIA.name
  rdf_property :pages, N::DCT.pages

  # Local bibliography item, the kind we already have
  rdf_property :bibliography_item, N::TALIA.bibliographyItem, :type => TaliaCore::ActiveSource

  # remote bibliography item, probably a URI for some bibl-store somewhere on the interwebs
  # TODO: change type :string to .. ActiveSource? Another active type? Something new?
  rdf_property :remote_bibliography_item, N::TALIA.remoteBibliographyItem, :type => :string

  after_save :clear_cached_fragments

  def clear_cached_fragments 

    ActionController::Base.new.expire_fragment('custom_biblio', options = nil)
    ActionController::Base.new.expire_fragment('custom_biblio_with_options', options = nil)

  end 



  def boxview_data
    i = self.bibliography_item
    title = [i.author, i.title, i.published_in, i.publisher, i.date, self.pages].compact.join(', ')
    { :controller => 'boxview/bibliography_item',
      :title => title,
      :description => "",
      :res_id => "bibliography_item_#{self.id}",
      :box_type => '',
      :thumb => nil
    }

  end
  
end
