class IconclassTerm < TaliaCore::SourceTypes::SkosConcept
  hobo_model # Don't put anything above this
  include StandardPermissions
  extend RandomId
  
  # Already declared on base class
  declare_attr_type :pref_label, :string
  declare_attr_type :name, :string
  # We have a single alt label at the moment (!)
  singular_property :alt_label, N::SKOS.altLabel
  declare_attr_type :alt_label, :string
  singular_property :soundex, N::TALIA.soundex
  declare_attr_type :soundex, :string
  singular_property :note, N::SKOS.editorialNote
  declare_attr_type :note, :text
  declare_attr_type :term, :string
  
  def self.create_term(options = {})
    options.to_options!
    term = options.delete(:term)
    raise(ArgumentError, 'No term') unless(term)
    options[:uri] = make_uri(term)
    raise(ArgumentError, "Record already exists #{options[:uri]}") if(TaliaCore::ActiveSource.exists?(options[:uri]))
    self.new(options)
  end
  
  def name
    term || uri.local_name
  end
  
  def name=(value)
    term = value
  end
  
  def term
    # Term is the local name of the uri. Trailing slash needs to be slashed.
    self.uri.to_s.blank? ? '' : CGI.unescape(self.uri.to_s[0..-2].to_uri.local_name)
  end
  
  def term=(value)
    self.uri = self.class.make_uri(value)
  end
  
  def self.find_by_term(term)
    find(make_uri(term))
  end
  
  private
  
  # Creates the uri for the given term
  def self.make_uri(term)
    'http://www.iconclass.org/rkd/' << CGI.escape(term.gsub(' ', '')) << '/'
  end
  
  
end