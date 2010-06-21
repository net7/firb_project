require File.dirname(__FILE__) + '/../test_helper'

class ProcessionTest < ActiveSupport::TestCase
  
  include TaliaUtil::TestHelpers
  suppress_fixtures
  
  def setup
    setup_once(:flush) do
      TaliaUtil::Util.flush_db
      TaliaUtil::Util.flush_rdf
      true
    end
    
    setup_once(:procession) do
      procession = Procession.new(:title => "Bar")
      procession << FiParadeCartCard.new(:name => "Pflonk")
      procession << FirbParadeCharacterCard.new(:name => "Foo")
      procession << FirbParadeCharacterCard.new(:name => "Bar")
      procession.save!
      procession
    end
  
    @procession.reload
    assert(@procession.valid?)
  end
  
  
  def test_size
    assert_equal(3, @procession.size)
  end
  
  def test_cart_size
    assert_equal("Pflonk", @procession.cart.name)
  end
  
  def test_characters_size
    assert_equal(2, @procession.characters.size)
  end

  def test_valid
    assert(@procession.valid?)
  end

  def test_valid_type
    @procession << TaliaCore::ActiveSource.new(:uri => 'http://foobar.com/testthenthingagainandsoon')
    assert(!@procession.valid?)
  end
  
  def test_valid_too_many_carts
    @procession << FiParadeCartCard.new(:name => 'foobar')
    assert(!@procession.valid?)
  end

end