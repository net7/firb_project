require File.dirname(__FILE__) + '/../test_helper'

class BibliographyItemTest < ActiveSupport::TestCase
  
  include TaliaUtil::TestHelpers
  suppress_fixtures
  
  def setup
    setup_once(:flush) do
      TaliaUtil::Util.flush_db
      TaliaUtil::Util.flush_rdf
      true
    end
    setup_once(:item) do
      BibliographyItem.create_item(:title => 'bingobongo',
      :abstract => 'all about bingobongos',
      :publisher => 'the man of bingobongo',
      :author => 'the bingobongo',
      :date => '01-10-1991',
      :doi => '123456',
      :isbn => '7890',
      :issn => 'abcde',
      :pages => '1-12',
      :published_in => 'journal of bongo',
      :external_url => 'http://bingobongo.org')
    end
  end
  
  def test_title
    assert_equal('bingobongo', @item.title)
  end
  
  def test_abstract
    assert_equal('all about bingobongos', @item.abstract)
  end
  
  def test_publisher
    assert_equal('the man of bingobongo', @item.publisher)
  end
  
  def test_author
    assert_equal('the bingobongo', @item.author)
  end
  
  def test_date
    assert_equal('01-10-1991', @item.date)
  end
  
  def test_doi
    assert_equal('123456', @item.doi)
  end
  
  def test_isbn
    assert_equal('7890', @item.isbn)
  end
  
  def test_issn
    assert_equal('abcde', @item.issn)
  end
  
  def test_pages
    assert_equal('1-12', @item.pages)
  end
  
  def test_published_in
    assert_equal('journal of bongo', @item.published_in)
  end
  
  def test_pages
    assert_equal('http://bingobongo.org', @item.external_url)
  end
  
end