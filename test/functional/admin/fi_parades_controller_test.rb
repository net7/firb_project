require File.dirname(__FILE__) + '/../../test_helper'

class Admin::FiParadesControllerTest < ActionController::TestCase

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
    setup_parade
    login_for(:admin)
    get(:index)
    assert_response :success
  end

  def test_show
    flunk
  end
  
  def test_create
    login_for(:admin)
    assert_difference('TaliaCore::Collection.count', 1) do
      post(:create, :talia_collection => { :title => 'Meee new title' })
      assert_response 302
    end
    new_parade = FiParade.last
    assert_equal('Meee new title', new_parade.title)
  end
  
  def test_create_non_authorized
    assert_difference('TaliaCore::Collection.count', 0) do
      post(:create, :talia_collection => { :title => 'Meee new title'})
      assert_response 403
    end
  end
  
  def test_update
    flunk
  end
  
  def test_update_non_authorized
    flunk
  end
  
  def test_destroy
    flunk
  end
  
  def test_destroy_non_authorized
    flunk
  end
  
  private 
  
  def setup_parade
    @parade = FiParade.new(:title => "Foobar")
    @parade.save!
  end
  
end