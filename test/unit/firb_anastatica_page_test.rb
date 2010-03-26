require File.dirname(__FILE__) + '/../test_helper'

class FirbImageTest < ActiveSupport::TestCase
  
  def test_create
    page = FirbAnastaticaPage.create_page
    assert_kind_of(FirbAnastaticaPage, page)
    assert_not_nil(page.uri)
    assert_match(/[^\s]+/, page.uri.to_s)
  end
  
  def test_create_with_save
    assert_nothing_raised { FirbAnastaticaPage.create_page.save! }
  end
  
  def test_create_with_options
    page = FirbAnastaticaPage.create_page(:title => "tito", :page_position => "ups")
    assert_equal("ups", page.page_position)
    assert_equal("tito", page.title)
  end
  
end