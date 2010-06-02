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
    setup_additional_cards
    login_for(:admin)
    get(:index, :type => 'letter_illustration')
    assert_response(:success)
    assert_select('ul.collection') { assert_select('li.item', 1)}
  end
  
  def test_index_parent
    setup_additional_cards
    login_for(:admin)
    get(:index, :type => 'parent_illustration')
    assert_response(:success)
    assert_select('ul.collection') { assert_select('li.item', 1)}
  end

  def test_show_letter
    setup_additional_cards
    login_for(:admin)
    get(:show, :type => 'parent_illustration', :id => @parent.id)
    assert_response(:success)
  end
  
  def test_show_illustrated
    setup_cards
    login_for(:admin)
    get(:show, :type => 'illustrated_memory_depiction', :id => @illustrated_one.id)
    assert_response(:success)
  end

  def test_show_illustrated
    setup_cards
    login_for(:admin)
    get(:show, :type => 'non_illustrated_memory_depiction', :id => @non_illustrated.id)
    assert_response(:success)
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

  def test_create_non_illustrated_non_authorized
    assert_difference('FirbNonIllustratedMemoryDepictionCard.count', 0) do
      post(:create, :firb_non_illustrated_memory_depiction_card => { :name => 'New one', :position => 'last_and_first', :anastatica => '' }, :type => 'non_illustrated_memory_depiction')
      assert_response(403)
    end
  end

  def test_create_non_illustrated_with_page
    setup_page
    login_for(:admin)
    assert_difference('FirbNonIllustratedMemoryDepictionCard.count', 1) do
      post(:create, :firb_non_illustrated_memory_depiction_card => { :name => 'New one', :position => 'last_and_first', :anastatica => @page.uri.to_s }, :type => 'non_illustrated_memory_depiction')
      assert_redirected_to(:controller => :firb_cards, :action => :index)
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
    login_for(:admin)
    assert_difference('FirbIllustratedMemoryDepictionCard.count', 1) do
      post(:create, 
        :firb_illustrated_memory_depiction_card => { :name => 'New illu', :position => 'last_and_first', :anastatica => '', :bibliography_items => @bibliography_arr }, 
        :type => 'illustrated_memory_depiction' )
      assert_redirected_to(:controller => :firb_cards, :action => :index)
    end
    new_card = FirbIllustratedMemoryDepictionCard.last
    assert_equal('New illu', new_card.name)
    assert_equal('last_and_first', new_card.position)
    assert_property(new_card.bibliography_items, *@bibliographies)
  end

  def test_create_letter_with_zone_and_iconclass
    setup_page
    setup_iconclass
    setup_image_zone
    login_for(:admin)
    assert_difference('FirbLetterIllustrationCard.count', 1) do
      post(:create, 
        :firb_letter_illustration_card => { :name => 'Letter', :position => 'last_and_first', :anastatica => '', :bibliography_items => '', :image_zone => @image_zone.uri.to_s, :iconclass_terms => @iconclass_arr }, 
        :type => 'letter_illustration' )
      assert_redirected_to(:controller => :firb_cards, :action => :index)
    end
    new_card = FirbLetterIllustrationCard.last
    assert_equal('Letter', new_card.name)
    assert_equal('last_and_first', new_card.position)
    assert_property(new_card.iconclass_terms, *@iconclasses)
    assert_equal(new_card.image_zone.uri, @image_zone.uri)
  end
  
  def test_create_letter_with_component
    setup_page
    setup_image_zone
    login_for(:admin)
    assert_difference('FirbLetterIllustrationCard.count', 1) do
      assert_difference('ImageComponent.count', 1) do
        post(:create, 
          :firb_letter_illustration_card => { :name => 'Plonker', :position => 'last_and_first', :anastatica => '', :bibliography_items => '', :image_components => [{ :name => "FOOX", :zone_type => "BAR", :image_zone => @image_zone.uri.to_s }] }, 
          :type => 'letter_illustration' )
      assert_redirected_to(:controller => :firb_cards, :action => :index)
      end
    end
    new_card = FirbLetterIllustrationCard.last
    assert_equal('Plonker', new_card.name)
    assert_equal('last_and_first', new_card.position)
    assert_equal(1, new_card.image_components.size)
  end
  
  def test_create_letter_with_existing_component
    setup_page
    setup_image_zone
    login_for(:admin)
    compo = ImageComponent.new(:name => "FOOZ", :zone_type => "BAR", :image_zone => @image_zone.uri.to_s)
    compo.save!
    assert_difference('FirbLetterIllustrationCard.count', 1) do
      assert_difference('ImageComponent.count', 1) do
        post(:create, 
          :firb_letter_illustration_card => { :name => 'Plonker', :position => 'last_and_first', :anastatica => '', :bibliography_items => '', :image_components => [{ :name => "FOOX", :zone_type => "BAR", :image_zone => @image_zone.uri.to_s }, {:uri => compo.uri.to_s }] }, 
          :type => 'letter_illustration' )
      assert_redirected_to(:controller => :firb_cards, :action => :index)
      end
    end
    new_card = FirbLetterIllustrationCard.last
    assert_equal('Plonker', new_card.name)
    assert_equal('last_and_first', new_card.position)
    assert_equal(2, new_card.image_components.size)
  end
  
  def test_create_letter_with_zone_and_iconclass_codes
    setup_page
    setup_iconclass
    setup_image_zone
    login_for(:admin)
    assert_difference('FirbLetterIllustrationCard.count', 1) do
      post(:create, 
        :firb_letter_illustration_card => { :name => 'Letter', :position => 'last_and_first', :anastatica => '', :bibliography_items => '', :image_zone => @image_zone.uri.to_s, :iconclass_terms => @iconclass_term_arr }, 
        :type => 'letter_illustration' )
      assert_redirected_to(:controller => :firb_cards, :action => :index)
    end
    new_card = FirbLetterIllustrationCard.last
    assert_equal('Letter', new_card.name)
    assert_equal('last_and_first', new_card.position)
    assert_property(new_card.iconclass_terms, *@iconclasses)
    assert_equal(new_card.image_zone.uri, @image_zone.uri)
  end
  
  def test_destroy
    setup_card
    login_for(:admin)
    assert_difference('FirbNonIllustratedMemoryDepictionCard.count', -1) do
      post(:destroy, :id => @non_illustrated.id)
      assert_response(302)
    end
    assert(!FirbNonIllustratedMemoryDepictionCard.exists?(@non_illustrated.id))
  end

  def test_destroy_non_authorized
    setup_card
    assert_difference('FirbNonIllustratedMemoryDepictionCard.count', 0) do
      post(:destroy, :id => @non_illustrated.id)
      assert_response(403)
    end
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
    login_for(:admin)
    post(:update, :id => @non_illustrated.id, 
      :firb_non_illustrated_memory_depiction_card => { :name => 'changed', :position => 'last_and_first', :anastatica => @page.uri.to_s }, 
      :type => 'non_illustrated_memory_depiction')
    assert_redirected_to(:action => :show, :id => @non_illustrated.id)
    card = FirbNonIllustratedMemoryDepictionCard.find(@non_illustrated.id)
    assert_equal('changed', card.name)
    assert_equal('last_and_first', card.position)
    assert_kind_of(FirbAnastaticaPage, card.anastatica)
    assert_equal(card.anastatica.uri, @page.uri)
  end

  def test_update_illustrated_with_bibliography
    setup_cards
    setup_bibliographies
    login_for(:admin)
    post(:update, :id => @illustrated_one.id, 
      :firb_illustrated_memory_depiction_card => { :name => 'changed', :position => 'last_and_first', :bibliography_items => @bibliography_arr },
      :type => 'illustrated_memory_depiction')
    assert_redirected_to :controller => :firb_cards, :action => :show
    card = FirbIllustratedMemoryDepictionCard.find(@illustrated_one.id)
    assert_equal('changed', card.name)
    assert_equal('last_and_first', card.position)
    assert_property(card.bibliography_items, *@bibliographies)
  end
  
  def test_update_letter_with_component
    setup_image_zone
    card =  FirbLetterIllustrationCard.new(:name => "compy test",
      :image_zone => @image_zone.uri,
      :image_components => [ {
        :name => "FOOX", :zone_type => "BAR", :image_zone => @image_zone
    }])
    card.save!
    component = ImageComponent.last
    login_for(:admin)
    assert_difference("ImageComponent.count", 0) do
      post(:update, :id => card.id, 
        :firb_letter_illustration_card => { :name => 'changed', :image_components => [ { :name => "FOOZ", :zone_type => "BAR", :image_zone => @image_zone }]},
        :type => 'letter_illustration')
      assert_redirected_to :controller => :firb_cards, :action => :show
    end
    card = FirbLetterIllustrationCard.find(card.id)
    assert_equal(1, card.image_components.size)
    assert_equal('FOOZ', card.image_components.first.name)
  end
  
  def test_update_letter_with_component
    setup_image_zone
    card =  FirbLetterIllustrationCard.new(:name => "compy test",
      :image_zone => @image_zone.uri,
      :image_components => [ {
        :name => "FOOX", :zone_type => "BAR", :image_zone => @image_zone
    }])
    card.save!
    component = ImageComponent.last
    login_for(:admin)
    assert_difference("ImageComponent.count", -1) do
      post(:update, :id => card.id, 
        :firb_letter_illustration_card => { :name => 'changed', :image_components => [ ]},
        :type => 'letter_illustration')
      assert_redirected_to :controller => :firb_cards, :action => :show
    end
    card = FirbLetterIllustrationCard.find(card.id)
    assert_equal(0, card.image_components.size)
  end
  
  def test_update_letter_with_component_adding
    setup_image_zone
    card =  FirbLetterIllustrationCard.new(:name => "compy test",
      :image_zone => @image_zone.uri,
      :image_components => [ {
        :name => "FOOX", :zone_type => "BAR", :image_zone => @image_zone
    }])
    card.save!
    component = ImageComponent.last
    login_for(:admin)
    assert_difference("ImageComponent.count", 1) do
      post(:update, :id => card.id, 
        :firb_letter_illustration_card => { :name => 'changed', :image_components => [ {:uri => component.uri.to_s }, { :name => "FOOZ", :zone_type => "BAR", :image_zone => @image_zone } ]},
        :type => 'letter_illustration')
      assert_redirected_to :controller => :firb_cards, :action => :show
    end
    card = FirbLetterIllustrationCard.find(card.id)
    assert_equal(2, card.image_components.size)
    assert(ImageComponent.exists?(component.id))
  end
  
  def test_update_non_authorized
    setup_card
    old_position = @non_illustrated.position
    post(:update, :id => @non_illustrated.id, 
      :firb_non_illustrated_memory_depiction_card => { :name => 'changed', :position => 'last_and_first', :bibliography_items => '' },
      :type => 'non_illustrated_memory_depiction')
    assert_response(403)
    assert_equal(FirbCard.find(@non_illustrated.id).position, old_position)
  end


  def setup_cards
    @non_illustrated = FirbNonIllustratedMemoryDepictionCard.new(:name => 'me title', :position => '3rb')
    @non_illustrated.save!
    @illustrated_one = FirbIllustratedMemoryDepictionCard.new(:name => 'illuostrous', :position => 'whatever')
    @illustrated_one.save!
    @illustrated_two = FirbIllustratedMemoryDepictionCard.new(:name => 'super_illu', :position => 'you guess')
    @illustrated_two.save!
  end
  
  def setup_additional_cards
    @parent = FirbParentIllustrationCard.new(:name => 'madre', :position => 'on top')
    @parent.save!
    @letter = FirbLetterIllustrationCard.new(:name => 'Letter', :position => 'first')
    @letter.save!
  end
  
  def setup_card
    @non_illustrated = FirbNonIllustratedMemoryDepictionCard.new(:name => 'me title', :position => '3rb')
    @non_illustrated.save!
  end

  def setup_iconclass
    @iconclasses = []
    @iconclass_arr = []
    @iconclass_term_arr = []
    (0..1).each do |idx|
      iconclass = IconclassTerm.create_term(:term => "61 E (+#{idx})", 
        :pref_label => 'foo', 
        :alt_label => 'bar',
        :soundex => 'meep',
        :note => 'Cool' )
      iconclass.save!
      @iconclasses << iconclass
      @iconclass_arr << iconclass.uri.to_s
      @iconclass_term_arr << iconclass.term
    end
  end
  
  def setup_image_zone
    @image_zone = FirbImageZone.create_with_name('hello')
    @image_zone.save!
  end

  def setup_bibliographies
    @bibliographies = []
    (0..2).each do |idx|
      bibliography = BibliographyItem.new(:title => "bib_#{idx}")
      bibliography.save!
      @bibliographies << bibliography
    end
    @bibliography_arr = @bibliographies.collect { |bib| bib.uri.to_s }
  end

  def setup_page
    @page = FirbAnastaticaPage.new(:title => "meep", :page_positon => "1", :name => "first page")
    @page.save!
    @page
  end

end