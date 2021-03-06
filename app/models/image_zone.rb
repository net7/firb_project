class ImageZone < ImageElement
  hobo_model # Don't put anything above this
  include StandardPermissions
  
  attr_accessor :image
  singular_property :coordinates, N::TALIA.hasCoordinates
  ## declare_attr_type :name, :string
  
  fields do
    uri :string
  end
  
  # Creates a new zone. You must pass in the image object to which this zone will 
  # be connected. Optionally, you may also pass in a parent zone
  def self.create_with_name(name)
    new_url = N::LOCAL + 'zones/' + random_id
    raise(ArgumentError, "Record already exists #{new_url}") if(TaliaCore::ActiveSource.exists?(new_url))
    zone = self.new(new_url)
    zone.name = name 
    zone
  end
  
  # Removes the zone and all of its children
  def remove    
    # Remove all of its subzones
    zones.each{|z| z.remove }
    
    parent = self.get_parent
    parent[N::TALIA.hasSubZone].remove(self)

    self.destroy
    parent.save
  end

  # Gets the parent of this ImageZone, either another ImageZone or
  # an Image object
  def get_parent
    qry = ActiveRDF::Query.new(ImageZone).select(:parent).distinct
    qry.where(:parent, N::TALIA.hasSubZone, self)
    qry.where(:parent, N::RDF.type, N::TALIA.ImageZone)
    parent = qry.execute

    if(parent.empty?)
      qry = ActiveRDF::Query.new(Image).select(:parent).distinct
      qry.where(:parent, N::TALIA.hasSubZone, self)
      qry.where(:parent, N::RDF.type, N::TALIA.Image)
      parent = qry.execute
    end
    
    parent.first
  end
  
  # Will recurse on its parents to get the Image
  def get_image_parent
    parent = self.get_parent
    loop do
      break if (parent.nil? or parent.class.to_s == "Image")
      parent = parent.get_parent
    end
    parent
  end
  
  # TODO: delete this method if the new implementation in image_element is working fine
  # Produces an hash to be passed to an input (select_for) format
  # with all of our ImageZones
  def self.get_all_zones_array_old
    foo = ImageZone.all.collect do |a|
      parent = a.get_parent
      breadcrumbs = ""
      while(parent.class.to_s != "Image" && !parent.nil?)
        breadcrumbs = parent.name + " > " + breadcrumbs 
        parent = parent.get_parent
      end
      breadcrumbs = parent.name_label + " > " + breadcrumbs unless parent.nil?
      breadcrumbs += a.name.nil? ? I18n.t("text_card.no_name_zone") : a.name
      
      [breadcrumbs, a.uri.to_s]
    end
    foo.sort
  end

  
  def self.find_by_name(name)
    ActiveRDF::Query.new(ImageZone).select(:zone).where(:zone).where(:zone, N::TALIA.name, name).execute.first
  end

  # Returns the XML describing the polygon that this zone contains
  def polygon
  end
  
  # Set the polygon XML for this zone
  def polygon=(xml)
  end


  # we've used two different predicate for the zones ...
  # TODO: in the ontology make N::TALIA.image_zone a subclass of N::DCT.isFormatOf
  def get_related_objects
    res = self.inverse[N::DCT.isFormatOf]
    return self.inverse[N::TALIA.image_zone] if res.empty?
    return res
  end
  
end
