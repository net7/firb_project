require File.dirname(__FILE__) + '/../../test_helper'
Dir[File.join(File.dirname(__FILE__), 'card_tests', '*.rb')].each { |file| require file.gsub(/\.rb\Z/, '') }

class Admin::BaseCardsControllerTest < ActionController::TestCase

  include TaliaUtil::TestHelpers
  include CardSetups
  include FiCards

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
    get(:index, :type => 'pi_non_illustrated_m_d_card')
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
    get(:index, :type => 'pi_letter_illustration_card')
    assert_response(:success)
    assert_select('ul.collection') { assert_select('li.item', 1)}
  end
  
  def test_index_parent
    setup_additional_cards
    login_for(:admin)
    get(:index, :type => 'pi_illustration_card')
    assert_response(:success)
    assert_select('ul.collection') { assert_select('li.item', 1)}
  end

  def test_show_letter
    setup_additional_cards
    login_for(:admin)
    get(:show, :type => 'pi_illustration_card', :id => @parent.id)
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
    get(:show, :type => 'pi_non_illustrated_m_d_card', :id => @non_illustrated.id)
    assert_response(:success)
  end


  # def test_show
  #   login_for(:admin)
  #   get(:show, :id => @page.id)
  #   assert_response(:success)
  #   assert_select 'div.page-position', "Page position: #{@page.page_position}"
  #   assert_select 'span.anastatica-name', @page.name
  # end
  # 
  def test_new_non_illustrated
    login_for(:admin)
    get(:new, :type => 'pi_non_illustrated_m_d_card')
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
    get(:new, :type => 'pi_letter_illustration_card')
    assert_response(:success)
    # assert_select 'th.page-position-label'
  end

  def test_new_parent
    login_for(:admin)
    get(:new, :type => 'pi_illustration_card')
    assert_response(:success)
    # assert_select 'th.page-position-label'
  end

  def test_create_non_illustrated_non_authorized
    assert_difference('PiNonIllustratedMdCard.count', 0) do
      post(:create, :pi_non_illustrated_m_d_card => { :name => 'New one', :position => 'last_and_first', :anastatica => '' }, :type => 'pi_non_illustrated_m_d_card')
      assert_response(403)
    end
  end

  def test_create_non_illustrated_with_page
    setup_page
    login_for(:admin)
    assert_difference('PiNonIllustratedMdCard.count', 1) do
      post(:create, :pi_non_illustrated_m_d_card => { :name => 'New one', :position => 'last_and_first', :anastatica => @page.uri.to_s }, :type => 'pi_non_illustrated_m_d_card')
      assert_redirected_to(:controller => :base_cards, :action => :index)
    end
    new_card = PiNonIllustratedMdCard.last
    assert_equal('New one', new_card.name)
    assert_equal('last_and_first', new_card.position)
    assert_kind_of(Anastatica, new_card.anastatica)
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
      assert_redirected_to(:controller => :base_cards, :action => :index)
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
    assert_difference('PiLetterIllustrationCard.count', 1) do
      post(:create, 
        :pi_letter_illustration_card => { :name => 'Letter', :position => 'last_and_first', :anastatica => '', :bibliography_items => '', :image_zone => @image_zone.uri.to_s, :iconclass_terms => @iconclass_arr }, 
        :type => 'pi_letter_illustration_card' )
      assert_redirected_to(:controller => :base_cards, :action => :index)
    end
    new_card = PiLetterIllustrationCard.last
    assert_equal('Letter', new_card.name)
    assert_equal('last_and_first', new_card.position)
    assert_property(new_card.iconclass_terms, *@iconclasses)
    assert_equal(new_card.image_zone.uri, @image_zone.uri)
  end
  
  def test_create_letter_with_component
    setup_page
    setup_image_zone
    login_for(:admin)
    assert_difference('PiLetterIllustrationCard.count', 1) do
      assert_difference('ImageComponent.count', 1) do
        post(:create, 
          :pi_letter_illustration_card => { :name => 'Plonker', :position => 'last_and_first', :anastatica => '', :bibliography_items => '', :image_components => [{ :name => "FOOX", :zone_type => "BAR", :image_zone => @image_zone.uri.to_s }] }, 
          :type => 'pi_letter_illustration_card' )
      assert_redirected_to(:controller => :base_cards, :action => :index)
      end
    end
    new_card = PiLetterIllustrationCard.last
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
    assert_difference('PiLetterIllustrationCard.count', 1) do
      assert_difference('ImageComponent.count', 1) do
        post(:create, 
          :pi_letter_illustration_card => { :name => 'Plonker', :position => 'last_and_first', :anastatica => '', :bibliography_items => '', :image_components => [{ :name => "FOOX", :zone_type => "BAR", :image_zone => @image_zone.uri.to_s }, {:uri => compo.uri.to_s }] }, 
          :type => 'pi_letter_illustration_card' )
      assert_redirected_to(:controller => :base_cards, :action => :index)
      end
    end
    new_card = PiLetterIllustrationCard.last
    assert_equal('Plonker', new_card.name)
    assert_equal('last_and_first', new_card.position)
    assert_equal(2, new_card.image_components.size)
  end
  
  def test_create_letter_with_zone_and_iconclass_codes
    setup_page
    setup_iconclass
    setup_image_zone
    login_for(:admin)
    assert_difference('PiLetterIllustrationCard.count', 1) do
      post(:create, 
        :pi_letter_illustration_card => { :name => 'Letter', :position => 'last_and_first', :anastatica => '', :bibliography_items => '', :image_zone => @image_zone.uri.to_s, :iconclass_terms => @iconclass_term_arr }, 
        :type => 'pi_letter_illustration_card' )
      assert_redirected_to(:controller => :base_cards, :action => :index)
    end
    new_card = PiLetterIllustrationCard.last
    assert_equal('Letter', new_card.name)
    assert_equal('last_and_first', new_card.position)
    assert_property(new_card.iconclass_terms, *@iconclasses)
    assert_equal(new_card.image_zone.uri, @image_zone.uri)
  end
  
  def test_destroy
    setup_card
    login_for(:admin)
    assert_difference('PiNonIllustratedMdCard.count', -1) do
      post(:destroy, :id => @non_illustrated.id)
      assert_response(302)
    end
    assert(!PiNonIllustratedMdCard.exists?(@non_illustrated.id))
  end

  def test_destroy_non_authorized
    setup_card
    assert_difference('PiNonIllustratedMdCard.count', 0) do
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
      :pi_non_illustrated_m_d_card => { :name => 'changed', :position => 'last_and_first', :anastatica => @page.uri.to_s }, 
      :type => 'pi_non_illustrated_m_d_card')
    assert_redirected_to(:action => :show, :id => @non_illustrated.id)
    card = PiNonIllustratedMdCard.find(@non_illustrated.id)
    assert_equal('changed', card.name)
    assert_equal('last_and_first', card.position)
    assert_kind_of(Anastatica, card.anastatica)
    assert_equal(card.anastatica.uri, @page.uri)
  end

  def test_update_illustrated_with_bibliography
    setup_cards
    setup_bibliographies
    login_for(:admin)
    post(:update, :id => @illustrated_one.id, 
      :firb_illustrated_memory_depiction_card => { :name => 'changed', :position => 'last_and_first', :bibliography_items => @bibliography_arr },
      :type => 'illustrated_memory_depiction')
    assert_redirected_to :controller => :base_cards, :action => :show
    card = FirbIllustratedMemoryDepictionCard.find(@illustrated_one.id)
    assert_equal('changed', card.name)
    assert_equal('last_and_first', card.position)
    assert_property(card.bibliography_items, *@bibliographies)
  end
  
  def test_update_letter_with_component
    setup_image_zone
    card =  PiLetterIllustrationCard.new(:name => "compy test",
      :image_zone => @image_zone.uri,
      :image_components => [ {
        :name => "FOOX", :zone_type => "BAR", :image_zone => @image_zone
    }])
    card.save!
    component = ImageComponent.last
    login_for(:admin)
    assert_difference("ImageComponent.count", 0) do
      post(:update, :id => card.id, 
        :pi_letter_illustration_card => { :name => 'changed', :image_components => [ { :name => "FOOZ", :zone_type => "BAR", :image_zone => @image_zone }]},
        :type => 'pi_letter_illustration_card')
      assert_redirected_to :controller => :base_cards, :action => :show
    end
    card = PiLetterIllustrationCard.find(card.id)
    assert_equal(1, card.image_components.size)
    assert_equal('FOOZ', card.image_components.first.name)
  end
  
  def test_update_letter_with_component
    setup_image_zone
    card =  PiLetterIllustrationCard.new(:name => "compy test",
      :image_zone => @image_zone.uri,
      :image_components => [ {
        :name => "FOOX", :zone_type => "BAR", :image_zone => @image_zone
    }])
    card.save!
    component = ImageComponent.last
    login_for(:admin)
    assert_difference("ImageComponent.count", -1) do
      post(:update, :id => card.id, 
        :pi_letter_illustration_card => { :name => 'changed', :image_components => [ ]},
        :type => 'pi_letter_illustration_card')
      assert_redirected_to :controller => :base_cards, :action => :show
    end
    card = PiLetterIllustrationCard.find(card.id)
    assert_equal(0, card.image_components.size)
  end
  
  def test_update_letter_with_component_adding
    setup_image_zone
    card =  PiLetterIllustrationCard.new(:name => "compy test",
      :image_zone => @image_zone.uri,
      :image_components => [ {
        :name => "FOOX", :zone_type => "BAR", :image_zone => @image_zone
    }])
    card.save!
    component = ImageComponent.last
    login_for(:admin)
    assert_difference("ImageComponent.count", 1) do
      post(:update, :id => card.id, 
        :pi_letter_illustration_card => { :name => 'changed', :image_components => [ {:uri => component.uri.to_s }, { :name => "FOOZ", :zone_type => "BAR", :image_zone => @image_zone } ]},
        :type => 'pi_letter_illustration_card')
      assert_redirected_to :controller => :base_cards, :action => :show
    end
    card = PiLetterIllustrationCard.find(card.id)
    assert_equal(2, card.image_components.size)
    assert(ImageComponent.exists?(component.id))
  end
  
  def test_update_non_authorized
    setup_card
    old_position = @non_illustrated.position
    post(:update, :id => @non_illustrated.id, 
      :pi_non_illustrated_m_d_card => { :name => 'changed', :position => 'last_and_first', :bibliography_items => '' },
      :type => 'pi_non_illustrated_m_d_card')
    assert_response(403)
    assert_equal(BaseCard.find(@non_illustrated.id).position, old_position)
  end


  def setup_cards
    @non_illustrated = PiNonIllustratedMdCard.new(:name => 'me title', :position => '3rb')
    @non_illustrated.save!
    @illustrated_one = PiIllustratedMDCard.new(:name => 'illuostrous', :position => 'whatever')
    @illustrated_one.save!
    @illustrated_two = PiIllustratedMDCard.new(:name => 'super_illu', :position => 'you guess')
    @illustrated_two.save!
  end
  
  def setup_additional_cards
    @parent = PiIllustrationCard.new(:name => 'madre', :position => 'on top')
    @parent.save!
    @letter = PiLetterIllustrationCard.new(:name => 'Letter', :position => 'first')
    @letter.save!
  end
  
  def setup_card
    @non_illustrated = PiNonIllustratedMdCard.new(:name => 'me title', :position => '3rb')
    @non_illustrated.save!
  end

end