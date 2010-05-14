class ImageComponent < TaliaCore::Source
  hobo_model # Don't put anything above this
  include StandardPermissions
  extend RdfProperties
  extend RandomId
  
  rdf_property :name, N::TALIA.name
  rdf_property :zone_type, N::DCT.type
  rdf_property :firb_card, N::TALIA.image_component
  rdf_property :image_zone, N::TALIA.image_zone
  
  def self.create_component(options = {})
    options.to_options!
    new_url =  (N::LOCAL + 'image_component/' + random_id).to_s
    options[:uri] = new_url
    options[:image_zone] = FirbImageZone.find(options[:image_zone]) unless(options[:image_zone].blank?)
    options[:firb_card] = TaliaCore::ActiveSource.find(options[:firb_card]) unless(options[:firb_card].blank?)
    raise(ArgumentError, "Illegal card uri") unless(options[:firb_card].blank? || options[:firb_card].is_a?(FirbCard))
    raise(ArgumentError, "Record already exists #{new_url}") if(TaliaCore::ActiveSource.exists?(new_url))
    self.new(options)
  end
  
end