require File.dirname(__FILE__) + '/../../test_helper'

class Admin::BibliographyItemsControllerTest < ActionController::TestCase

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
    testing_items
    login_for(:admin)
    get(:index)
    assert_response(:success)
    assert_select('ul.collection') { assert_select('li', 2) }
  end

  def test_show
    testing_items
    login_for(:admin)
    item = BibliographyItem.first
    get(:show, :id => item.id)
    assert_response(:success)
    assert_select('h2.heading', item.title)
  end
  
  
  def test_new
    login_for(:admin)
    get(:new)
    assert_response(:success)
    assert_select 'input#bibliography_item_title'
    assert_select 'textarea#bibliography_item_abstract'
    assert_select 'input#bibliography_item_publisher'
    assert_select 'input#bibliography_item_author'
    assert_select 'input#bibliography_item_date'
    assert_select 'input#bibliography_item_doi'
    assert_select 'input#bibliography_item_isbn'
    assert_select 'input#bibliography_item_issn'
    assert_select 'input#bibliography_item_pages'
    assert_select 'input#bibliography_item_published_in'
    assert_select 'input#bibliography_item_external_url'
  end
  
  def test_create
    login_for(:admin)
    assert_difference('BibliographyItem.count', 1) do
      post(:create, :bibliography_item => { :title => 'da noob', :abstract => 'all about noobsys',
      :author => 'the bingobongo',
      :date => '01-10-1991',
      :doi => '123456'})
      assert_redirected_to(:action => 'index')
    end
    item = BibliographyItem.last
    assert_equal('da noob', item.title)
    assert_equal('all about noobsys', item.abstract)
    assert_equal('the bingobongo', item.author)
    assert_equal('01-10-1991', item.date)
    assert_equal('123456', item.doi)
    assert_equal(nil, item.isbn)
  end
  
  def test_update
    login_for(:admin)
    testing_items
    item = BibliographyItem.last
    post(:update, :id => item.id, :bibliography_item => { :title => 'the new bongo', :isbn => 'Naboo' })
    assert_response(:redirect)
    item = BibliographyItem.find(item.id)
    assert_equal('the new bongo', item.title)
    assert_equal('Naboo', item.isbn)
  end
  
  def test_update_more
    login_for(:admin)
    testing_items
    item = BibliographyItem.last
    post(:update, "page_path"=>"admin/bibliography_items/edit", "bibliography_item"=>{"title"=>"Tit", "abstract"=>"Abstract", "publisher"=>"Foo", "author"=>"Bard", "date"=>"", "doi"=>"", "isbn"=>"", "issn"=>"", "pages"=>"", "published_in"=>"", "external_url"=>""}, "id"=>item.id)
    assert_response(:redirect)
    item = BibliographyItem.find(item.id)
    assert_equal('Tit', item.title)
    assert_equal('abstract', item.abstract)
  end

  private

  def testing_items
    @item_definitions = [
      {
        :title => 'da bingobongo, first part',
        :abstract => 'all about bingobongos',
        :publisher => 'the man of bingobongo',
        :author => 'the bingobongo',
        :date => '01-10-1991',
        :doi => '123456',
        :isbn => '7890',
        :issn => 'abcde',
        :pages => '1-12',
        :published_in => 'journal of bongo',
        :external_url => 'http://bingobongo.org'
      },
      {
        :title => 'da bingobongo, second part',
        :abstract => 'all about bingobongos',
        :publisher => 'the man of bingobongo',
        :author => 'the bingobongo',
        :date => '01-11-1991',
        :doi => '123457',
        :isbn => '7891',
        :issn => 'abcdf',
        :pages => '1-23',
        :published_in => 'journal of bongo',
        :external_url => 'http://bingobongo.org/part_two'
      }
    ]
    @item_definitions.each { |item| BibliographyItem.create_item(item).save! }
  end

end