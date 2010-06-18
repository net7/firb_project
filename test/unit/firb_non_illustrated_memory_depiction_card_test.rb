require File.dirname(__FILE__) + '/../test_helper'

class PiNonIllustratedMDCardTest < ActiveSupport::TestCase
  
  include TaliaUtil::TestHelpers
  suppress_fixtures
  
  def setup
    setup_once(:flush) do
      TaliaUtil::Util.flush_db
      TaliaUtil::Util.flush_rdf
      true
    end
    setup_once(:card) do
      source = PiNonIllustratedMDCard.new(
      :name => "evil guy",
      :code => "codyhoo"
      )
      
      source.save!
      source
    end
    
    assert_not_nil(@card)
  end
  
  def test_create
    card = PiNonIllustratedMDCard.new
    assert_kind_of(PiNonIllustratedMDCard, card)
    assert_not_nil(card.uri)
    assert_match(/[^\s]+/, card.uri.to_s)
  end
  
  def test_create_with_save
    assert_nothing_raised { BaseCard.new.save! }
  end
  
  def test_create_with_options
    card = PiNonIllustratedMDCard.new(:name => "tito", :position => "ups")
    assert_equal("ups", card.position)
    assert_equal("tito", card.name)
  end
  
  def test_name
    assert_equal(@card.name, "evil guy")
  end
  
  def test_code
    assert_equal(@card.code, "codyhoo")
  end
  
end