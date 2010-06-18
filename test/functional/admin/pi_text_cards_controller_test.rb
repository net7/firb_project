require File.dirname(__FILE__) + '/../../test_helper'

class Admin::PiTextCardsControllerTest < ActionController::TestCase

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
    setup_blank_card
    login_for(:admin)
    get(:index)
    assert_response(:success)
    assert_select('h2.heading')
    assert_select('ul.collection') { assert_select('li.item', 1) }
  end

  def test_show
    setup_blank_card
    login_for(:admin)
    get(:show, :id => @card.id)
    assert_response(:success)
  end

  def test_new
    login_for(:admin)
    get(:new)
    assert_response(:success)
  end

  def test_create_with_non_illustrated
    setup_non_illustrated
    login_for(:admin)
    assert_difference('PiTextCard.count', 1) do
      post(:create, :pi_text_card => { :title => 'foo', :non_illustrated_memory_depictions => @non_illustrated })
      assert_redirected_to(:controller => :pi_text_cards, :action => :index)
    end
    new_card = PiTextCard.last
    assert_equal('foo', new_card.title)
    assert_equal(2, new_card.non_illustrated_memory_depictions.size)
  end
  
  def test_create_with_zone_and_anastatica
    setup_image_zone
    setup_anastatica
    login_for(:admin)
    assert_difference('PiTextCard.count', 1) do
      post(:create, :pi_text_card => { :title => 'foo', :anastatica => @anastatica, :image_zones => [ @image_zone.uri.to_s ] })
      assert_redirected_to(:controller => :pi_text_cards, :action => :index)
    end
    new_card = PiTextCard.last
    assert_equal(@anastatica.uri, new_card.anastatica.uri)
    assert_equal(1, new_card.image_zones.size)
  end
  
  def test_create_non_authorized
    assert_difference('PiTextCard.count', 0) do
      post(:create, :pi_text_card => { :title => 'foo' })
      assert_response(403)
    end
  end
  

  def test_edit
    setup_blank_card
    login_for(:admin)
    get(:edit, :id => @card.id)
    assert_response(:success)
  end

  def test_update_with_all_new
    setup_blank_card
    setup_image_zone
    setup_anastatica
    setup_non_illustrated
    login_for(:admin)
    post(:update, :id => @card.id, 
      :pi_text_card => { :title => 'changed', :anastatica => @anastatica, 
        :image_zones => [ @image_zone.uri.to_s ],
        :non_illustrated_memory_depictions => @non_illustrated })
    assert_redirected_to :controller => :pi_text_cards, :action => :index
    card = PiTextCard.find(@card.id)
    assert_equal('changed', card.title)
    assert_equal(@anastatica.uri, card.anastatica.uri)
    noicards = PiNonIllustratedMDCard.all
    assert_property(card.non_illustrated_memory_depictions, *noicards)
    assert_property(card.image_zones, @image_zone)
  end

  def test_update_with_new_non_illustrated
    setup_blank_card
    login_for(:admin)
    assert_difference("PiNonIllustratedMDCard.count", 1) do
      post(:update, :id => @card.id, 
        :pi_text_card => { :title => 'changed', 
          :non_illustrated_memory_depictions => [{ :name => "FOOZ" }] })
      assert_redirected_to :controller => :pi_text_cards, :action => :index
    end
    card = PiTextCard.find(@card.id)
    assert_equal('changed', card.title)
    assert_property(card.non_illustrated_memory_depictions, *PiNonIllustratedMDCard.all)
  end
  
  def test_update_with_new_existing_non_illustrated
    setup_blank_card
    setup_non_illustrated
    @card.non_illustrated_memory_depictions = PiNonIllustratedMDCard.all
    @card.save
    to_delete = PiNonIllustratedMDCard.first
    login_for(:admin)
    assert_difference("PiNonIllustratedMDCard.count", 0) do
      post(:update, :id => @card.id, 
        :pi_text_card => { :title => 'changed', 
          :non_illustrated_memory_depictions => [{ :name => "FOOZ" }, PiNonIllustratedMDCard.last ] })
      assert_redirected_to :controller => :pi_text_cards, :action => :index
    end
    card = PiTextCard.find(@card.id)
    assert_equal('changed', card.title)
    assert(!PiNonIllustratedMDCard.exists?(to_delete.id))
    assert_equal(2, card.non_illustrated_memory_depictions.size)
  end

  def test_update_non_authorized
    setup_blank_card
    post(:update, :id => @card.id, 
      :pi_text_card => { :title => 'changed' })
    assert_response 403
  end
  
  def test_destroy_with_non_illustrated
    setup_blank_card
    setup_non_illustrated
    @card.non_illustrated_memory_depictions = PiNonIllustratedMDCard.all
    @card.save
    login_for(:admin)
    assert_difference("PiTextCard.count", -1) do
      assert_difference("PiNonIllustratedMDCard.count", -2) do
        post(:destroy, :id => @card.id)
        assert_redirected_to :controller => :pi_text_cards, :action => :index
      end
    end
  end
  
  def test_destroy
    setup_blank_card
    login_for(:admin)
    assert_difference("PiTextCard.count", -1) do
      post(:destroy, :id => @card.id)
      assert_redirected_to :controller => :pi_text_cards, :action => :index
    end
  end
  
  def test_destroy_non_authorized
    setup_blank_card
    assert_difference("PiTextCard.count", 0) do
      post(:destroy, :id => @card.id)
      assert_response 403
    end
  end
  
  private
  
  def setup_non_illustrated
    @non_illustrated = (1..2).collect do |idx|
      card = PiNonIllustratedMDCard.new(:name => "FOO#{idx}")
      card.save!
      { :uri => card.uri.to_s }
    end
  end
  
  def setup_blank_card
    @card = PiTextCard.create_card(:title => 'Foo')
    @card.save!
    TaliaUtil::Util.flush_rdf
  end
  
  def setup_anastatica
    @anastatica = Anastatica.new(:title => "meep", :page_positon => "1", :name => "first page")
    @anastatica.save!
  end
  
  def setup_image_zone
    @image_zone = ImageZone.create_with_name('hello')
    @image_zone.save!
  end

end