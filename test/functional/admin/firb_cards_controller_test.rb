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
  def test_new_non_illustrated
    login_for(:admin)
    get(:new, :type => 'non_illustrated_memory_depiction')
    assert_response(:success)
    # assert_select 'th.page-position-label'
  end 

  def test_new_illustrated
    login_for(:admin)
    get(:new, :type => 'illustrated_memory_depiction')
    assert_response(:success)
    # assert_select 'th.page-position-label'
  end
  
  def test_new_letter
    login_for(:admin)
    get(:new, :type => 'letter_illustration')
    assert_response(:success)
    # assert_select 'th.page-position-label'
  end

  def test_new_parent
    login_for(:admin)
    get(:new, :type => 'parent_illustration')
    assert_response(:success)
    # assert_select 'th.page-position-label'
  end

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

  def test_create_illustrated_with_bibliography
    setup_page
    setup_bibliographies
    assert_difference('FirbIllustratedMemoryDepictionCard.count', 1) do
      post(:create, 
        :firb_illustrated_memory_depiction_card => { :name => 'New illu', :position => 'last_and_first', :anastatica => '', :bibliography => @bibliography_hash }, 
        :type => 'illustrated_memory_depiction' )
      assert_redirected_to(:controller => :firb_cards, :action => :index)
    end
    new_card = FirbIllustratedMemoryDepictionCard.last
    assert_equal('New illu', new_card.name)
    assert_equal('last_and_first', new_card.position)
    assert_equal(3, new_card.bibliography_items.size)
  end

  def test_create_letter_with_zone_and_iconclass
    setup_page
    setup_iconclass
    setup_image_zone
    assert_difference('FirbLetterIllustrationCard.count', 1) do
      post(:create, 
        :firb_letter_illustration_card => { :name => 'Letter', :position => 'last_and_first', :anastatica => '', :bibliography => '', :image_zone => @image_zone.uri.to_s, :iconclass => @iconclass_hash }, 
        :type => 'letter_illustration' )
      assert_redirected_to(:controller => :firb_cards, :action => :index)
    end
    new_card = FirbLetterIllustrationCard.last
    assert_equal('Letter', new_card.name)
    assert_equal('last_and_first', new_card.position)
    assert_equal(2, new_card.iconclass_terms.size)
    assert_equal(new_card.image_zone.uri, @image_zone.uri)
  end
  
  def test_create_letter_with_zone_and_iconclass_codes
    setup_page
    setup_iconclass
    setup_image_zone
    assert_difference('FirbLetterIllustrationCard.count', 1) do
      post(:create, 
        :firb_letter_illustration_card => { :name => 'Letter', :position => 'last_and_first', :anastatica => '', :bibliography => '', :image_zone => @image_zone.uri.to_s, :iconclass => @iconclass_term_hash }, 
        :type => 'letter_illustration' )
      assert_redirected_to(:controller => :firb_cards, :action => :index)
    end
    new_card = FirbLetterIllustrationCard.last
    assert_equal('Letter', new_card.name)
    assert_equal('last_and_first', new_card.position)
    assert_equal(2, new_card.iconclass_terms.size)
    assert_equal(new_card.image_zone.uri, @image_zone.uri)
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
    post(:update, :id => @non_illustrated.id, 
      :firb_non_illustrated_memory_depiction_card => { :name => 'changed', :position => 'last_and_first', :anastatica => @page.uri.to_s }, 
      :type => 'non_illustrated_memory_depiction')
    assert_response(302)
    card = FirbNonIllustratedMemoryDepictionCard.find(@non_illustrated.id)
    assert_equal('changed', card.name)
    assert_equal('last_and_first', card.position)
    assert_kind_of(FirbAnastaticaPage, card.anastatica)
    assert_equal(card.anastatica.uri, @page.uri)
  end

  def test_update_illustrated_with_bibliography
    setup_cards
    setup_bibliographies
    post(:update, :id => @illustrated_one.id, 
      :firb_illustrated_memory_depiction_card => { :name => 'changed', :position => 'last_and_first', :bibliography => @bibliography_hash },
      :type => 'illustrated_memory_depiction')
    assert_redirected_to :controller => :firb_cards, :action => :show
    card = FirbIllustratedMemoryDepictionCard.find(@illustrated_one.id)
    assert_equal('changed', card.name)
    assert_equal('last_and_first', card.position)
    assert_equal(3, card.bibliography_items.size)
  end


  def setup_cards
    @non_illustrated = FirbNonIllustratedMemoryDepictionCard.create_card(:name => 'me title', :position => '3rb')
    @non_illustrated.save!
    @illustrated_one = FirbIllustratedMemoryDepictionCard.create_card(:name => 'illuostrous', :position => 'whatever')
    @illustrated_one.save!
    @illustrated_two = FirbIllustratedMemoryDepictionCard.create_card(:name => 'super_illu', :position => 'you guess')
    @illustrated_two.save!
  end

  def setup_iconclass
    @iconclasses = []
    @iconclass_hash = {}
    @iconclass_term_hash = {}
    (0..1).each do |idx|
      iconclass = IconclassTerm.create_term(:term => "61 E (+#{idx})", 
        :pref_label => 'foo', 
        :alt_label => 'bar',
        :soundex => 'meep',
        :note => 'Cool' )
      iconclass.save!
      @iconclasses << iconclass
      @iconclass_hash["bar_#{iconclass.uri.to_s.hash}"] = iconclass.uri.to_s
      @iconclass_term_hash["bar_#{iconclass.uri.to_s.hash}"] = iconclass.term
    end
  end
  
  def setup_image_zone
    @image_zone = FirbImageZone.create_with_name('hello')
    @image_zone.save!
  end

  def setup_bibliographies
    @bibliographies = []
    (0..2).each do |idx|
      bibliography = BibliographyItem.create_item(:title => "bib_#{idx}")
      bibliography.save!
      @bibliographies << bibliography
    end
    @bibliography_hash = {}
    @bibliographies.each { |bib| @bibliography_hash["foo_#{bib.uri.to_s.hash}"] = bib.uri.to_s }
    @bibliographies
  end

  def setup_page
    @page = FirbAnastaticaPage.create_page(:title => "meep", :page_positon => "1", :name => "first page")
    @page.save!
    @page
  end

end