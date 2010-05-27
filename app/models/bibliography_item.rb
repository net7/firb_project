class BibliographyItem < TaliaCore::SourceTypes::MarcontResource
  hobo_model # Don't put anything above this
  include StandardPermissions
  extend RandomId
  extend RdfProperties
  
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
  
  def self.create_item(options = {})
    options[:uri] = N::LOCAL + 'bibliographic_item/' + random_id
    raise(ArgumentError, "Record already exists #{options[:uri]}") if(TaliaCore::ActiveSource.exists?(options[:uri]))
    self.new(options)
  end
  
  def name
    title || uri.local_name
  end
  
  def name=(value)
    title = value
  end
  
end