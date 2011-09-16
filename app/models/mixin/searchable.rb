##
# Implements the methods needed to make this class insexable and searchable via SOLR:
#
# NOTE: for every class A that incluses this mixin, you'll need a corresponding SOLR::A class
#       that defines solr attributes. See any class in app/models/solr/ except Base for an example.
# 
# Provides:
#
# #to_solr Returns an object that can be safely indexed in solr without worring about Talia, ActiveRecord or Hobo.
#
# #solr_index Indexes this object's values in solr (same as object.to_solr.solr_index), indexing is not done until SOLR.commit is called.
#
# #solr_index! Same as #solr_index followed by SOLR.commit.
module Mixin::Searchable
  delegate :solr_index, :solr_index!, :to => :to_solr

  def to_solr
    @to_solr ||= "SOLR::#{self.class.name}".constantize.from(self)
  rescue
    raise Exception, "No corresponding SOLR::#{self.class.name} class found"
  end
end
