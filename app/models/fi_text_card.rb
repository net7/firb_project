class FiTextCard < TextCard
  hobo_model
  include StandardPermissions

  include Mixin::Searchable
  include Mixin::Facetable::Fi

  autofill_uri :force => true

  setup_publish_properties

  rdf_property :title, N::DCNS.title

  # Edizione di riferimento
  multi_property :edition, N::TALIA.edition, :type => TaliaCore::ActiveSource

  # Numero pagina
  rdf_property :page_position, N::TALIA.position

  # Bibliografia
  multi_property :bibliography_items, N::TALIA.hasBibliography, :type => TaliaCore::ActiveSource

  fields do
    uri :string
  end

  # Produces an array of triples, where a triple is an array subject - predicate - object
  # meant to be used with rdf_builder's prepare_triples
  # TextFragment > hasBibliographyItem > BibliographyItem, for each cbi: self > relatedBibliographyItem > cbi
  def get_related_topic_descriptions
    triples = []

    # self > type+tabel
    triples.push [self.uri, N::RDF.type, self.type.to_s]
    triples.push [self.uri, N::RDFS.label, self.name.to_s]

    # TextFragment > hasBibliographyItem > BibliographyItem, for each cbi: self > relatedBibliographyItem > cbi
    CustomBibliographyItem.all.each do |cbi|
      triples.push [self.uri, N::FIRBSWN.relatedBibliographyItem, cbi.uri]
      triples.push [cbi.uri, N::RDF.type, N::FIRBSWN.BibliographyItem]
      triples.push [cbi.uri, N::RDFS.label, "#{cbi.name} (#{cbi.bibliography_item.author}: #{cbi.bibliography_item.title}) #{cbi.pages}"]
    end

    triples
  end

  def boxview_data
    
    # DEBUG: there could be just one edition, but the it's a 
    # collection anyway... just pick the last one.
#    self.edition.map do |item|
#      @title = "#{item.bibliography_item.author}: #{item.bibliography_item.title}, #{self.page_position}"

#    end
 
    @title = "#{self.title}, #{self.page_position}" 
   
    desc = self.title.nil? ? "" : "#{self.title.slice(0, 80)}.."
    { :controller => 'boxview/fi_text_cards', 
      :title => "Scheda testo: #{@title}", 
      :description => desc,
      :res_id => "fi_text_card_#{self.id}", 
      :box_type => 'transcription',
      :thumb => nil
    }
  end
end
