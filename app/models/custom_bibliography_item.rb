class CustomBibliographyItem < TaliaCore::Source
  hobo_model # Don't put anything above this
  include StandardPermissions
  extend RdfProperties
  
  autofill_uri :force => true
  
  rdf_property :name, N::TALIA.name
  rdf_property :pages, N::DCT.pages

  after_save :clear_cache

  def clear_cache
    expire fragment('custom_biblio_with_options')
  end

  # Local bibliography item, the kind we already have
  rdf_property :bibliography_item, N::TALIA.bibliographyItem, :type => TaliaCore::ActiveSource

  # remote bibliography item, probably a URI for some bibl-store somewhere on the interwebs
  # TODO: change type :string to .. ActiveSource? Another active type? Something new?
  rdf_property :remote_bibliography_item, N::TALIA.remoteBibliographyItem, :type => :string
  
end
