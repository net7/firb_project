class BookmarkCollection < TaliaCore::Collection
  hobo_model
  include TaliaUtil::UriHelper
  extend TaliaUtil::UriHelper
  include ActiveRDF::ResourceLike
  extend RandomId

  singular_property :name, N::DCT.title
  singular_property :notes, N::TALIA.notes
  singular_property :public, N::TALIA.public
  

  # constants to be used for :public property
  PUBLIC = 'true'
  PRIVATE = 'false'

  self.inheritance_column = 'foo'

  #  attr_reader :user_url, :url
  #
  #  alias :uri :url

  def self.create_bookmark_collection(options)
    options.to_options!
    public = options.delete(:public)
    new_thing = self.new(options)
    new_thing.uri = (N::LOCAL + "bookmark_notebook/" + random_id).to_s
    if public
      new_thing.public = PUBLIC
    else
      new_thing.public = PRIVATE
    end
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
    user.save!
  end
  
  def owner
    self.talia.owner.first
  end

  # Returns a SemanticCollectionWrapper with all the user following this Notebook
  def followers
    qry = ActiveRDF::Query.new(TaliaUser).select(:user).distinct
    qry.where(:user, N::TALIA.follows, self)
    qry.execute
  end

  # Toggles the public status of this bookmark collection
  def toggle_public
    new_status = PUBLIC
    new_status = PRIVATE if self.public == PUBLIC
    self.public = new_status
    self.save!
  end

  
end