class BookmarkCollection < TaliaCore::Collection
  hobo_model
  include TaliaUtil::UriHelper
  extend TaliaUtil::UriHelper
  include ActiveRDF::ResourceLike
  extend RandomId

  singular_property :name, N::DCT.title
  singular_property :notes, N::TALIA.notes
  singular_property :public, N::TALIA.public
  

  self.inheritance_column = 'foo'

  #  attr_reader :user_url, :url
  #
  #  alias :uri :url

  def self.create_bookmark_collection(options)
    options.to_options!
    new_thing = self.new(options)
    new_thing.uri = (N::LOCAL + "bookmark_notebook/" + random_id).to_s
    new_thing
  end

  def add_bookmark(bookmark)
    self << bookmark
    save!
  end

  def remove_bookmark(uri)
    elements.each do |bookmark|
      if (bookmark.uri.to_s == uri)
        delete(bookmark)
        bookmark.destroy
        save!
      end
    end
  end

  def set_owner(user)
    #TODO: be sure to delete possibile existing relations with users
    self.talia.owner << user
  end

  def add_follower(user)
    user.talia.follows << self
  end
  
  def owner
    self.talia.owner.first
  end

end