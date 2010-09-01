class BookmarkCollection < TaliaCore::Collection
  hobo_model
  extend RandomId

  # No need to create a :title property, it gets inherited 
  # from TaliaCore::Collection
  singular_property :notes, N::TALIA.notes
  singular_property :public, N::TALIA.public
  
  # constants to be used for :public property
  PUBLIC = 'true'
  PRIVATE = 'false'

  #  self.inheritance_column = 'foo'

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

  def detach_bookmark(uri)
    bookmark = TaliaCore::ActiveSource.find(uri)
    self.delete_at(self.index(bookmark))
    self.save!
    bookmark
  end

  def set_owner(user)
    owner = self[N::TALIA.owner]
    owner.remove
    owner << user
  end

  def add_follower(user)
    self.talia.followedBy << user
    self.save!
  end

  def remove_follower(user)
    followers.remove(user)
    self.save!
  end

  def owner
    self.talia.owner.first
  end

  # Returns a SemanticCollectionWrapper with all the user following this Notebook
  def followers
    self.talia.followedBy
  end

  def has_follower?(user)
    user.in? self.followers
  end

  # Toggles the public status of this bookmark collection
  def toggle_public
    new_status = PUBLIC
    new_status = PRIVATE if self.public == PUBLIC
    self.public = new_status
    self.save!
  end


  # override destroy method to remove also bookmarks related to it
  def destroy
    self.elements.each do |bookmark|
      bookmark = bookmark.becomes(TaliaBookmark)
      bookmark.destroy
    end
    super
  end
end