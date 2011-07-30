class ImageComponent < TaliaCore::Source
  hobo_model # Don't put anything above this
  include StandardPermissions
  extend RdfProperties
  extend Mixin::Showable
  showable_in PiIllustratedMdCard, PiLetterIllustrationCard
  autofill_uri :force => true
  
  rdf_property :name, N::TALIA.name
  rdf_property :zone_type, N::DCT.type
  rdf_property :image_zone, N::TALIA.image_zone, :type => TaliaCore::ActiveSource


  def self.zone_types_for(klass)
    qry = ActiveRDF::Query.new().select(:x).distinct
    qry.where(:ic, N::DCT.type, :x)
    qry.where(:ic, N::RDF.type, N::TALIA.ImageComponent)
    qry.where(:pimc, N::TALIA.image_component, :ic)
    qry.where(:pimc, N::RDF.type, N::TALIA+"#{klass.to_s}")
    qry.execute
  end

  def self.items_by_type_and_related_resource_class(type, resource_class)
    qry = ActiveRDF::Query.new(resource_class).select(:x).distinct
    qry.where(:x, N::TALIA.image_component, :ic)
    qry.where(:ic, N::DCT.type, :type)
    # teoretically we could use the type as the object of the above where clause,
    # but it adds a "^^<http://www.w3.org/2001/XMLSchema#string>" after it in the
    # SPARQL query, and it ends up finding none.
    # #filter is a method of the ActiveRDF::Query class too, but in my tests,
    # it always returned an empty "FILTER ()" clause, breaking the whole query.
    # Last chance we had was to use this one. I suppose it is the slowest of
    # the options, yet it seems to be the only one working.
    qry.regexp(:type, type)
    qry.where(:ic, N::RDF.type, N::TALIA.ImageComponent)
    qry.where(:x, N::RDF.type, N::TALIA+"#{resource_class.to_s}")
    qry.execute
    
  end
end
