require File.dirname(__FILE__) + '/../test_helper'

class ParadeTest < ActiveSupport::TestCase
  
  include TaliaUtil::TestHelpers
  suppress_fixtures
  
  def setup
    setup_once(:flush) do
      TaliaUtil::Util.flush_db
      TaliaUtil::Util.flush_rdf
      true
    end
    
    setup_once(:parade) do
      parade = Parade.new(:title => "Parade Title")
      parade << ParadeCart.new(:name => "first_foo")
      parade << ParadeCharacter.new(:name => "first_bar")
      parade << ParadeCharacter.new(:name => "second_bar")
      parade << ParadeCharacter.new(:name => "third_bar")
      parade << ParadeCart.new(:name => "second_foo")
      parade << ParadeCharacter.new(:name => "fourth_bar")
      parade.save!
      parade = Parade.find(parade.id)
    end
    
    assert_not_nil(@parade)
  end
  
  def test_all_elements
    assert_equal(6, @parade.size)
  end
  
  def test_characters
    chars = @parade.characters.collect { |c| c.name }
    assert_equal(%w(first_bar second_bar third_bar fourth_bar), chars)
  end
  
  def test_carts
    carts = @parade.carts.collect { |c| c.name }
    assert_equal(%w(first_foo second_foo), carts)
  end
  
  def test_title
    assert_equal(@parade.title, "Parade Title")
  end
end