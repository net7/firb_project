require File.dirname(__FILE__) + '/../test_helper'

class TaliaCollectionTest < ActiveSupport::TestCase
  
  def setup
    @collection = TaliaCollection.new
    @collection.uri = "http://testcollection.uri/"
    @collection.save!
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