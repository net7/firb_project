require File.dirname(__FILE__) + '/../../test_helper'

class Admin::IconclassTermsControllerTest < ActionController::TestCase

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
    testing_terms
    login_for(:admin)
    get(:index)
    assert_response(:success)
    assert_select('ul.collection') { assert_select('li.item', 6) }
  end

  def test_show
    testing_terms
    login_for(:admin)
    term = IconclassTerm.first
    get(:show, :id => term.id)
    assert_response(:success)
    assert_select('h2.heading', term.term)
  end
  
  
  def test_new
    login_for(:admin)
    get(:new)
    assert_response(:success)
    assert_select 'input#iconclass_term_term'
    assert_select 'input#iconclass_term_pref_label'
    assert_select 'input#iconclass_term_alt_label'
    assert_select 'input#iconclass_term_soundex'
    assert_select 'textarea#iconclass_term_note'
    assert_select 'input.submit-button'
  end
  
  def test_create
    login_for(:admin)
    assert_difference('IconclassTerm.count', 1) do
      post(:create, :iconclass_term => { :term => '99', :pref_label => 'Nuffink', :alt_label => 'Boink', :soundex => '12345', :note => 'Noo'})
      assert_redirected_to(:action => 'index')
    end
    term = IconclassTerm.last
    assert_equal('99', term.term)
    assert_equal('Nuffink', term.pref_label)
    assert_equal('Boink', term.alt_label)
    assert_equal('12345', term.soundex)
    assert_equal('Noo', term.note)
  end
  
  def test_create_non_authorized
    post(:create, :iconclass_term => { :term => '99', :pref_label => 'Nuffink', :alt_label => 'Boink', :soundex => '12345', :note => 'Noo'})
    assert_response(403)
  end
  
  def test_update
    login_for(:admin)
    testing_terms
    term = IconclassTerm.last
    post(:update, :id => term.id, :iconclass_term => { :term => '78B', :pref_label => 'Naboo' })
    assert_redirected_to(:action => 'index')
    term = IconclassTerm.find(term.id)
    # assert_equal('78B', term.term)
    assert_equal('Naboo', term.pref_label)
  end
  
  def test_update_non_authorized
    testing_terms
    term = IconclassTerm.last
    old_label = term.pref_label
    post(:update, :id => term.id, :iconclass_term => { :term => '78B', :pref_label => 'Naboo' })
    assert_response(403)
    assert_equal(IconclassTerm.last.pref_label, old_label)
  end
  
  def test_destroy
    login_for(:admin)
    testing_terms
    assert_difference("IconclassTerm.count", -1) do
      post(:destroy, :id => IconclassTerm.last.id)
      assert_redirected_to(:action => :index)
    end
  end
  
  def test_destroy_non_authorized
    testing_terms
    assert_difference("IconclassTerm.count", 0) do
      post(:destroy, :id => IconclassTerm.last.id)
      assert_response(403)
    end
  end
  
  def test_autocomplete_nonspecific
    check_autocomplete('2', '2', '21', '21E')
  end
  
  def test_autocomplete_more_specific
    check_autocomplete('21', '21', '21E')
  end
  
  def test_autocomplete_most_specific
    check_autocomplete('21E', '21E')
  end

  def test_autocomplete_pref_label_specific
    check_autocomplete('the four elements, and ether, the fifth element', '21')
  end
  
  def test_autocomplete_pref_label_nonspecific
    check_autocomplete('ether', '21E', '21')
  end
  
  def test_autocomplete_alt_label_nonspecific
    check_autocomplete('child', '32B(+5)', '61E(+0)')
  end

  def test_autocomplete_alt_label_nonspecific_case_insensitive
    check_autocomplete('CHILD', '32B(+5)', '61E(+0)')
  end

  private
  
  def check_autocomplete(term, *expected)
    login_for(:admin)
    testing_terms
    post(:autocomplete, :value => term)
    assert_response(:success)
    expected.each { |ex| assert_select('li', /#{Regexp.escape(ex)}/) }
  end

  def testing_terms
    @term_definitions = [
      {
        :term => '2', 
        :pref_label => 'Nature', 
        :alt_label => 'nature',
        :soundex => '12345',
        :note => ''
      },
      {
        :term => '21', 
        :pref_label => 'the four elements, and ether, the fifth element', 
        :alt_label => "elements · five · four · nature",
        :soundex => '12345',
        :note => 'Cool'
      },
      {
        :term => '21E', 
        :pref_label => "ether as 'quinta essentia", 
        :alt_label => 'elements · essentia · ether · five · four · nature · quinta essentia',
        :soundex => '12345',
        :note => ''
      },
      {
        :term => '5(+3)', 
        :pref_label => 'Abstract Ideas and Concepts (+ symbolical representation of concept)',
        :alt_label => 'abstract idea · allegory · idea · personification · symbol', 
        :soundex => 'meep',
        :note => 'Cool'
      },
      {
        :term => '32B(+5)', 
        :pref_label => 'human races; peoples; nationalities (+ babies and children)',
        :alt_label => 'age · baby · child · human being · nationality · race (human) · sex · young', 
        :soundex => '54321',
        :note => ''
      },
      {
        :term => '61 E (+0)', 
        :pref_label => 'correction of naughty children',
        :alt_label => 'child · civilization · correction · culture · family · naughtiness · offspring · parents · punishment · society',
        :soundex => 'm',
        :note => 'Cool'
      }
    ]
    @term_definitions.each { |term| IconclassTerm.create_term(term).save! }
  end

end