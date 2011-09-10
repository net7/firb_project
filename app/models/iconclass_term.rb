class IconclassTerm < TaliaCore::SourceTypes::SkosConcept
  hobo_model # Don't put anything above this
  include StandardPermissions
  extend RdfProperties
  
  # Already declared on base class
  declare_attr_type :pref_label, :string
  declare_attr_type :name, :string
  # We have a single alt label at the moment (!)
  rdf_property :alt_label, N::SKOS.altLabel
  rdf_property :note, N::SKOS.editorialNote, :type => :text
  declare_attr_type :term, :string
  
  def self.new(*params)
    if((params.size == 1) && params.first.is_a?(String) && !(params.first =~ /http:\/\//))
      super(make_uri(params.first))
    else
      super(*params)
    end
  end
  
  def self.find(*params)
    if((params.size == 1) && params.first.is_a?(String) && !(params.first =~ /http:\/\//))
      super(make_uri(params.first))
    else
      super(*params)
    end
  end
  
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
  

  def label
    self[:label].first.blank? ? self[:pref_label] : self[:label]
  end

  # Creates the uri for the given term
  def self.make_uri(term)
    'http://www.iconclass.org/rkd/' << CGI.escape(term.gsub(' ', '')) << '/'
  end

  
  def boxview_data
    desc = self.pref_label
    { :controller => 'boxview/iconclass', 
      :title => "Iconclass: #{self.pref_label}", 
      :description => desc,
      :res_id => "iconclass_#{self.id}", 
      :box_type => 'list',
      :thumb => nil
    }
  end

  # This is needed to use #sort on the array containing IconclassTerm
  def <=>(term)
    self.pref_label < term.pref_label ? -1 : 1
  end

  def self.items_starting_with(letter)
    qry = ActiveRDF::Query.new(IconclassTerm).select(:x).distinct
    qry.where(:x, N::RDF.type, N::TALIA.IconclassTerm)           
    qry.where(:x, N::SKOS.prefLabel, :pref_label)
    qry.regexp(:pref_label, "^#{letter}")
    qry.execute.sort
  end


  # @collection is a TaliaCore::Collection
  # returns the ordered list of groups to be shown in the menu list
  
  def self.menu_groups_for(collection)
  # it actually ignore the collection thing, it is there for compatibility with other menu
 #   letters = []
 #   ('A'..'Z').each do |letter|                           
 #     if IconclassTerm.items_for(letter).count > 0
 #       letters << letter                                           
 #     end


    ('A'..'Z')
#    end
  
  end




end
