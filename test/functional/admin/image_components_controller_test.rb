require File.dirname(__FILE__) + '/../../test_helper'

class Admin::ImageComponentsControllerTest < ActionController::TestCase

  include TaliaUtil::TestHelpers

  def setup
    # @page = FirbAnastaticaPage.create_page(:title => 'me title', :page_position => '3rb')
    # @page.save!
    TaliaUtil::Util.flush_rdf
  end

  def teardown
    TaliaUtil::Util.flush_db
  end

  def test_create
    setup_friends
    login_for(:admin)
    assert_difference("ImageComponent.count", 1) do
      post(:create, :image_component => { :name => 'nomy', :zone_type => 'xxx', :firb_card => @firb_card.uri.to_s, :image_zone => @image_zone.uri.to_s })
      assert_redirected_to(:controller => :image_components, :action => :index)
    end
  end

  def test_create
    setup_foo_card
    login_for(:admin)
    assert_difference("ImageComponent.count", 1) do
      post(:create, :image_component => { :name => 'nomy', :zone_type => 'xxx', :firb_card => @firb_card.uri.to_s })
      assert_redirected_to(:controller => :image_components, :action => :index)
    end
    assert_kind_of(FirbIllustratedMemoryDepictionCard, ImageComponent.last.firb_card)
    assert_equal(ImageComponent.last.firb_card.uri, @firb_card.uri)
  end

  def test_create_non_authorized
    setup_friends
    assert_difference("ImageComponent.count", 0) do
      post(:create, :image_component => { :name => 'nomy', :zone_type => 'xxx', :firb_card => @firb_card.uri.to_s, :image_zone => @image_zone.uri.to_s })
      assert_response(403)
    end
  end

  def test_destroy
    setup_component
    login_for(:admin)
    assert_difference("ImageComponent.count", -1) do
      post(:destroy, :id => @image_component.id)
      assert_redirected_to(:controller => :image_components, :action => :index)
    end
  end

  def test_destroy_non_authorized
    setup_component
    assert_difference("ImageComponent.count", 0) do
      post(:destroy, :id => @image_component.id)
      assert_response(403)
    end
  end

  def setup_friends
    @image_zone = FirbImageZone.create_with_name('foo')
    @image_zone.save!
    @firb_card = FirbCard.create_card
    @firb_card.save!
  end

  def setup_foo_card
    @firb_card = FirbIllustratedMemoryDepictionCard.create_card
    @firb_card.save!
  end

  def setup_component
    @image_component = ImageComponent.create_component(:name => 'nomy', :zone_type => 'xxx')
    @image_component.save!
  end

end