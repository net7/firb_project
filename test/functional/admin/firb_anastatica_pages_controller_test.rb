require File.dirname(__FILE__) + '/../../test_helper'

class Admin::FirbAnastaticaPagesControllerTest < ActionController::TestCase

  include TaliaUtil::TestHelpers

  def setup
    @page = FirbAnastaticaPage.new(:title => 'me title', :page_position => '3rb')
    @page.save!
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
    assert_select('div.aside')
    assert_select('h2.heading')
    assert_select('ul.collection') { assert_select('li.item', 1) }
  end

  def test_show
    login_for(:admin)
    get(:show, :id => @page.id)
    assert_response(:success)
    assert_select 'div.page-position', "#{I18n.t(:'firb_anastatica_pages.page_position')}: #{@page.page_position}"
    assert_select 'span.firb-anastatica-page-name', @page.name
  end

  def test_new
    login_for(:admin)
    get(:new)
    assert_response(:success)
    assert_select 'th.page-position-label'
    assert_select 'th.title-label'
    assert_select 'input.submit-button'
  end

  def test_create
    login_for(:admin)
    assert_difference('FirbAnastaticaPage.count', 1) do
      post(:create, :firb_anastatica_page => { :title => 'Noo titeel', :page_position => 'xvrzf' })
      assert_redirected_to(:controller => :firb_anastatica_pages, :action => :index)
    end
    new_page = FirbAnastaticaPage.last
    assert_equal('Noo titeel', new_page.title)
    assert_equal('xvrzf', new_page.page_position)
  end
  
  def test_create_non_authorized
    assert_difference('FirbAnastaticaPage.count', 0) do
      post(:create, :firb_anastatica_page => { :title => 'Noo titeel', :page_position => 'xvrzf' })
      assert_response(403)
    end
  end
  
  def test_create_different
    login_for(:admin)
    assert_difference('FirbAnastaticaPage.count', 1) do
      post(:create, "firb_anastatica_page"=> { "uri"=>"http://localhost:5000/",
       "page_position"=>"poh",
       "title"=>"doh" })
      assert_redirected_to(:controller => :firb_anastatica_pages, :action => :index)
    end
    new_page = FirbAnastaticaPage.last
    assert_equal('doh', new_page.title)
    assert_equal('poh', new_page.page_position)
    assert_not_equal('http://localhost:5000/', new_page.uri.to_s)
  end
  
  def test_create_with_image_zone
    login_for(:admin)
    image_zone = FirbImageZone.create_with_name('foo')
    image_zone.save!
    assert_difference('FirbAnastaticaPage.count', 1) do
      post(:create, "firb_anastatica_page"=> { "uri"=>"http://localhost:5000/",
       "page_position"=>"poh",
       "title"=>"doh",
       "image_zone" => image_zone.uri.to_s
        })
      assert_redirected_to(:controller => :firb_anastatica_pages, :action => :index)
    end
    new_page = FirbAnastaticaPage.last
    assert_equal('doh', new_page.title)
    assert_equal('poh', new_page.page_position)
    assert_equal(image_zone.uri, new_page.image_zone.uri)
  end

  def test_edit
    login_for(:admin)
    get(:edit, :id => @page.id)
    assert_response(:success)
    assert_select 'th.page-position-label'
    assert_select 'th.title-label'
    assert_select 'input.submit-button'
  end

  def test_update
    login_for(:admin)
    post(:update, :id => @page.id, :firb_anastatica_page => { :title => 'Noo titeel', :page_position => 'xvrzf' })
    assert_response(302)
    new_page = FirbAnastaticaPage.last
    assert_equal('Noo titeel', new_page.title)
    assert_equal('xvrzf', new_page.page_position)
  end

  def test_update_non_authorized
    old_title = @page.title
    post(:update, :id => @page.id, :firb_anastatica_page => { :title => 'Noo titeel', :page_position => 'xvrzf' })
    assert_response(403)
    assert_equal(FirbAnastaticaPage.find(@page.id).title, old_title)
  end
  
  def test_destroy
    login_for(:admin)
    assert_difference("FirbAnastaticaPage.count", -1) do
      post(:destroy, :id => FirbAnastaticaPage.last.id)
      assert_redirected_to(:action => :index)
    end
  end
  
  def test_destroy_non_authorized
    assert_difference("FirbAnastaticaPage.count", 0) do
      post(:destroy, :id => @page.id)
      assert_response(403)
    end
  end

end