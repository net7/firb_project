class TaliaBookmark < TaliaCore::Source

  extend RandomId
    
  singular_property :link, N::DCNS.url
  singular_property :title, N::DCNS.title
  singular_property :date, N::DCNS.date
  singular_property :notes, N::TALIA.notes
  singular_property :public, N::TALIA.public
  singular_property :resource_type, N::TALIA.resource_type

  def self.create_bookmark(options)
    options.to_options!
    new_thing = self.new(options)
    new_thing.date = Time.now
    new_thing.uri = (N::LOCAL.bookmark + '/' + random_id).to_s
    new_thing.public ||= false
    new_thing
  end
end