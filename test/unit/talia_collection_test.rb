require File.dirname(__FILE__) + '/../test_helper'

class TaliaCollectionTest < ActiveSupport::TestCase
  
  include TaliaUtil::TestHelpers
  suppress_fixtures
  
  def setup
    setup_once(:flush) do
      TaliaUtil::Util.flush_db
      TaliaUtil::Util.flush_rdf
      true
    end
    setup_once(:collection) do
      collection = TaliaCollection.new
      collection.uri = "http://testcollection.uri/"
      collection.save!
      collection
    end
  end
  
  def test_real_class
    assert_equal(TaliaCore::Collection, TaliaCollection.real_class)
  end
  
  def test_type
    assert_equal('TaliaCore::Collection', @collection.type)
  end
  
  def test_find
    assert_not_equal(0, TaliaCore::Collection.count)
    assert_equal(TaliaCore::Collection.all.collect { |r| TaliaCollection.send(:from_real_source, r) }, TaliaCollection.all)
  end
  
end