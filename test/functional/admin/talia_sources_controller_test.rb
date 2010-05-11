require File.dirname(__FILE__) + '/../../test_helper'

class Admin::TaliaSourcesControllerTest < ActionController::TestCase

  include TaliaUtil::TestHelpers

  def setup
    TaliaUtil::Util.flush_rdf
  end
  
  def teardown
    TaliaUtil::Util.flush_db
  end
  
  def test_index_login
    login_for(:admin)
    get(:index)
    assert_equal(@controller.send(:current_user), users(:admin))
  end

  def test_index
    test_collection
    login_for(:admin)
    get(:index)
    assert_response(:success)
  end

  
  def test_assign_collection_non_authorized
    collection = test_collection
    source = test_source
    assert_difference("TaliaCore::Collection.find(collection.uri).size", 0) do
      post(:assign_collection, :source => source.to_uri.safe_encoded, :collection => collection.to_uri.safe_encoded)
      assert_response(403)
    end
  end

  def test_assign_collection
    login_for(:admin)
    collection = test_collection
    source = test_source
    assert_difference("collection.size", 1) do
      post(:assign_collection, :source => source.to_uri.safe_encoded, :collection => collection.to_uri.safe_encoded)
      assert_response(:success)
      collection = TaliaCore::Collection.find(collection.uri) # reload
    end
    assert_equal(collection.last.uri, source.uri)
  end
  
  
  def test_assign_collection_double
    login_for(:admin)
    collection = test_collection
    assert_difference("collection.size", 0) do
      post(:assign_collection, :source => collection.first.to_uri.safe_encoded, :collection => collection.to_uri.safe_encoded)
      assert_response(:success)
      collection = TaliaCore::Collection.find(collection.uri) # reload
    end
  end
  
  def test_remove_collection_non_authorized
    collection = test_collection
    assert_difference("TaliaCore::Collection.find(collection.uri).size", 0) do
      post(:assign_collection, :source => collection.first.to_uri.safe_encoded, :collection => collection.to_uri.safe_encoded)
      assert_response(403)
    end
  end
  
  def test_remove_collection
    login_for(:admin)
    collection = test_collection
    assert_difference("collection.size", -1) do
      post(:remove_collection, :source => collection.first.to_uri.safe_encoded, :collection => collection.to_uri.safe_encoded)
      assert_response(:success)
      collection = TaliaCore::Collection.find(collection.uri) # reload
    end
  end

  private
  
  def test_source
    source = TaliaCore::Source.new('http://talia_source_functional/test_source')
    source.save!
    source
  end

  def test_collection
    collection = TaliaCore::Collection.new('http://talia_source_functional/collection')
    (0..4).each do |idx|
      source = TaliaCore::Source.new("http://talia_source_functional/collection/source#{idx}")
      collection << source
    end
    collection.save!
    collection
  end
end