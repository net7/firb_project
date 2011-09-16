module SOLR

  require File.join(File.dirname(__FILE__), 'solr', 'adapters')

  ##
  # Just a link to Sunspot commit method, to keep names consistent.
  #
  def self.commit
    Sunspot.commit
  end
end
