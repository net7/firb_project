require File.dirname(__FILE__) + '/../../test_helper'

class Admin::TaliaCollectionsControllerTest < ActionController::TestCase

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
    assert_select('ul.collection') { assert_select 'li.item' }
  end

  def test_show
    collection = test_collection
    login_for(:admin)
    get(:show, :id => collection.id)
    assert_response(:success)
    assert_select('ul#collection_order') { assert_select('li.item', 5) }
  end
  
  def test_reorder
    collection = test_collection
    element_ids = collection.elements.collect { |el| el.id.to_s }
    element_ids = element_ids.reverse
    login_for(:admin)
    post(:reorder, :id => collection.to_uri.safe_encoded, :collection_order => element_ids)
    assert_response(:success)
    collection = TaliaCore::Collection.find(collection.uri)
    assert_equal(collection.elements.collect { |el| el.id.to_s }, element_ids)
  end

  private

  def login_for(user)
    @request.cookies['auth_token'] =  "#{users(user).remember_token} #{users(user).class.name}"
  end

  def test_collection
    collection = TaliaCore::Collection.new('http://collection_functional/test')
    (0..4).each do |idx|
      source = TaliaCore::Source.new("http://collection_functional/test/source#{idx}")
      collection << source
    end
    collection.save!
    collection
  end

end
