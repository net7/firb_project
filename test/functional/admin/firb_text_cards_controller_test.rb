require File.dirname(__FILE__) + '/../../test_helper'

class Admin::FirbTextCardsControllerTest < ActionController::TestCase

  include TaliaUtil::TestHelpers

  def setup
    @card = FirbTextCard.create_card('Foo', nil, nil, [])
    @card.save!
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
    login_for(:admin)
    get(:index)
    assert_response(:success)
    assert_select('h2.heading')
    assert_select('ul.collection') { assert_select('li.item', 1) }
  end

  def test_show
    login_for(:admin)
    get(:show, :id => @card.id)
    assert_response(:success)
  end

  def test_new
    login_for(:admin)
    get(:new)
    assert_response(:success)
  end

  def test_create
    # TODO: IMPLEMENTATION
  end
  
  def test_create_non_authorized
    # TODO: IMPLEMENTATION
  end
  

  def test_edit
    login_for(:admin)
    get(:edit, :id => @card.id)
    assert_response(:success)
  end

  def test_update
    # TODO: IMPLEMENTATION
  end

  def test_update_non_authorized
    # TODO: IMPLEMENTATION
  end
  
  def test_destroy
    # TODO: IMPLEMENTATION
  end
  
  def test_destroy_non_authorized
    # TODO: IMPLEMENTATION
  end

end