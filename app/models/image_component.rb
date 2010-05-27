class ImageComponent < TaliaCore::Source
  hobo_model # Don't put anything above this
  include StandardPermissions
  extend RdfProperties
  extend RandomId
  
  rdf_property :name, N::TALIA.name
  rdf_property :zone_type, N::DCT.type
  rdf_property :image_zone, N::TALIA.image_zone, :force_relation => true
  
  def self.create_component(options = {})
    options.to_options!
    new_url =  (N::LOCAL + 'image_component/' + random_id).to_s
    options[:uri] = new_url
    self.new(options)
  end
  
end