class BookmarkCollection < TaliaCore::Collection
  include TaliaUtil::UriHelper
  extend TaliaUtil::UriHelper
  include ActiveRDF::ResourceLike

#  attr_reader :user_url, :url
#
#  alias :uri :url

end