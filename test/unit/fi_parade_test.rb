require File.dirname(__FILE__) + '/../test_helper'

class FiParadeTest < ActiveSupport::TestCase
  
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
      parade << FiProcession.new(:name => "first_foo")
      parade << FiProcession.new(:name => "first_bar")
      parade.save!
      parade
    end
    
    @parade.reload
    assert(@parade.valid?)
  end
  
  def test_all_elements
    assert_equal(2, @parade.size)
  end
  
  def test_validation
    assert(@parade.valid?)
    @parade << TaliaCore::ActiveSource.new(:uri => N::TALIA.TestTheRest)
    assert(!@parade.valid?)
  end
end