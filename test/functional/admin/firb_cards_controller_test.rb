require File.dirname(__FILE__) + '/../../test_helper'

class Admin::FirbCardsControllerTest < ActionController::TestCase

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

  def test_index_non_illustrated
    setup_cards
    login_for(:admin)
    get(:index, :type => 'non_illustrated_memory_depiction')
    assert_response(:success)
    assert_select('ul.collection') { assert_select('li.item', 1) }
  end
  
  def test_index_illustrated
    setup_cards
    login_for(:admin)
    get(:index, :type => 'illustrated_memory_depiction')
    assert_response(:success)
    assert_select('ul.collection') { assert_select('li.item', 2) }
  end
  
  def test_index_letter
    setup_cards
    login_for(:admin)
    get(:index, :type => 'letter_illustration')
    assert_response(:success)
    assert_select('ul.collection', 0)
  end

  # def test_show
  #   login_for(:admin)
  #   get(:show, :id => @page.id)
  #   assert_response(:success)
  #   assert_select 'div.page-position', "Page position: #{@page.page_position}"
  #   assert_select 'span.firb-anastatica-page-name', @page.name
  # end
  # 
  # def test_new
  #   login_for(:admin)
  #   get(:new)
  #   assert_response(:success)
  #   assert_select 'th.page-position-label'
  #   assert_select 'th.title-label'
  #   assert_select 'input.submit-button'
  # end 
  
  def test_create_non_illustrated_with_page
    setup_page
    assert_difference('FirbNonIllustratedMemoryDepictionCard.count', 1) do
      post(:create, :firb_non_illustrated_memory_depiction_card => { :name => 'New one', :position => 'last_and_first', :anastatica => @page.uri.to_s }, :type => 'non_illustrated_memory_depiction')
      assert_response(302)
    end
    new_card = FirbNonIllustratedMemoryDepictionCard.last
    assert_equal('New one', new_card.name)
    assert_equal('last_and_first', new_card.position)
    assert_kind_of(FirbAnastaticaPage, new_card.anastatica)
    assert_equal(new_card.anastatica.uri, @page.uri)
  end
  
  # def test_edit
  #   login_for(:admin)
  #   get(:edit, :id => @page.id)
  #   assert_response(:success)
  #   assert_select 'th.page-position-label'
  #   assert_select 'th.title-label'
  #   assert_select 'input.submit-button'
  # end
  
   def test_update_non_illustrated_with_page
     setup_cards
     setup_page
     post(:update, :id => @non_illustrated.id, :firb_non_illustrated_memory_depiction_card => { :name => 'changed', :position => 'last_and_first', :anastatica => @page.uri.to_s }, :type => 'non_illustrated_memory_depiction')
     assert_response(302)
     card = FirbNonIllustratedMemoryDepictionCard.find(@non_illustrated.id)
     assert_equal('changed', card.name)
     assert_equal('last_and_first', card.position)
     assert_kind_of(FirbAnastaticaPage, card.anastatica)
     assert_equal(card.anastatica.uri, @page.uri)
   end
 

  def setup_cards
    @non_illustrated = FirbNonIllustratedMemoryDepictionCard.create_card(:name => 'me title', :position => '3rb')
    @non_illustrated.save!
    @illustrated_one = FirbIllustratedMemoryDepictionCard.create_card(:name => 'illuostrous', :position => 'whatever')
    @illustrated_one.save!
    @illustrated_two = FirbIllustratedMemoryDepictionCard.create_card(:name => 'super_illu', :position => 'you guess')
    @illustrated_two.save!
  end
  
  def setup_page
    @page = FirbAnastaticaPage.create_page(:title => "meep", :page_positon => "1", :name => "first page")
    @page.save!
    @page
  end

end