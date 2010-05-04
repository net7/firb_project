require File.dirname(__FILE__) + '/../test_helper'

class FirbLetterIllustrationCardTest < ActiveSupport::TestCase
  
  include TaliaUtil::TestHelpers
  suppress_fixtures
  
  def setup
    setup_once(:flush) do
      TaliaUtil::Util.flush_db
      TaliaUtil::Util.flush_rdf
      true
    end
    setup_once(:card) do
      source = FirbLetterIllustrationCard.create_card(
      :name => "evil guy",
      :code => "codyhoo"
      )
      
      source.save!
      source
    end
    
    assert_not_nil(@card)
  end
  
  def test_create
    card = FirbLetterIllustrationCard.create_card
    assert_kind_of(FirbLetterIllustrationCard, card)
    assert_not_nil(card.uri)
    assert_match(/[^\s]+/, card.uri.to_s)
  end
  
  def test_create_with_save
    assert_nothing_raised { FirbLetterIllustrationCard.create_card.save! }
  end
  
  def test_create_with_options
    card = FirbLetterIllustrationCard.create_card(:name => "tito", :code => "ups")
    assert_equal("ups", card.code)
    assert_equal("tito", card.name)
  end
  
  def test_name
    assert_equal(@card.name, "evil guy")
  end
  
  def test_code
    assert_equal(@card.code, "codyhoo")
  end
  
end