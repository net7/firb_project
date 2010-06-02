require File.dirname(__FILE__) + '/../../test_helper'

class Admin::ParadesControllerTest < ActionController::TestCase

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
    flunk
  end

  def test_show
    flunk
  end
  
  def test_create
    flunk
  end
  
  def test_create_non_authorized
    flunk
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
end