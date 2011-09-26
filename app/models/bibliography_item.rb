class BibliographyItem < TaliaCore::SourceTypes::MarcontResource
  hobo_model # Don't put anything above this
  include StandardPermissions
  extend RdfProperties
  
  autofill_uri
  
  rdf_property :ref_name, N::DCNS.title
  rdf_property :title, N::MARCONT.title
  rdf_property :abstract, N::MARCONT.abstract, :type => :text
  rdf_property :publisher, N::MARCONT.hasPublisher
  rdf_property :author, N::MARCONT.author
  rdf_property :date, N::MARCONT.hasDate
  rdf_property :doi, N::MARCONT.hasDOI
  rdf_property :isbn, N::MARCONT.hasISBN
  rdf_property :issn, N::MARCONT.hasISSN
  rdf_property :pages, N::MARCONT.hasPages
  rdf_property :published_in, N::MARCONT.publishedIn
  rdf_property :external_url, N::MARCONT.hasURL
  rdf_property :curator, N::TALIA.curator
  rdf_property :translator, N::TALIA.translator

  after_save :clear_cache

  def clear_cache
        expire fragment('biblio_item')
  end
  
  def name
    title || uri.local_name
  end
  
  def name=(value)
    title = value
  end
  
  # For the list select
  def to_list_s
    "#{ref_name} (#{author}: #{title})"
  end
end
