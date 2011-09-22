module SOLR

  require File.join(File.dirname(__FILE__), 'solr', 'adapters')

  ##
  # Just a link to Sunspot commit method, to keep names consistent.
  #
  def self.commit
    Sunspot.commit
  end

  ##
  # Just a link to Sunspot search method, to keep names consistent.
  #
  def self.search(*types, &block)
    Sunspot.search(*types, &block)
  end

  ##
  # Just a link to Sunspot setup method, to keep names consistent.
  #
  def self.setup(clazz, &block)
    Sunspot.setup(clazz, &block)
  end

  ##
  # Just a link to Sunspot remove method, to keep names consistent.
  #
  def self.remove(*objects, &block)
    Sunspot.remove(*objects, &block)
  end

  ##
  # Just a link to Sunspot remove_all! method, to keep names consistent.
  #
  def self.remove_all!
    Sunspot.remove_all!
  end
end
