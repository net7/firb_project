class BookmarkCollection < TaliaCore::Collection
  
  include TaliaUtil::UriHelper
  extend TaliaUtil::UriHelper
  include ActiveRDF::ResourceLike

  self.inheritance_column = 'foo'

  #  attr_reader :user_url, :url
  #
  #  alias :uri :url

  def remove_bookmark(uri)
    elements.each do |bookmark|
      if (bookmark.uri.to_s == uri)
        delete(bookmark)
        bookmark.destroy
        save!
      end
    end
  end
end