class FiTextCard < TextCard

  hobo_model
  include StandardPermissions
  autofill_uri :force => true

  rdf_property :title, N::DCNS.title

  # Edizione di riferimento
  rdf_property :edition, N::TALIA.edition, :type => TaliaCore::ActiveSource

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
    triples.push [self.uri.to_s, N::RDFS.type, self.type.to_s]
    triples.push [self.uri.to_s, N::RDFS.label, self.name.to_s]

    # TextFragment > hasBibliographyItem > BibliographyItem, for each cbi: self > relatedBibliographyItem > cbi
    CustomBibliographyItem.all.each do |cbi|
      triples.push [self.uri.to_s, N::FIRBSWN.relatedBibliographyItem, cbi.uri.to_s]
      triples.push [cbi.uri.to_s, N::RDFS.type, N::FIRBSWN.BibliographyItem]
      triples.push [cbi.uri.to_s, N::RDFS.label, "#{cbi.name} (#{cbi.bibliography_item.author}: #{cbi.bibliography_item.title}) #{cbi.pages}"]
    end
    
    triples
  end
      
end