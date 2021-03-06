require File.dirname(__FILE__) + '/../test_helper'

class PiIllustratedMdCardTest < ActiveSupport::TestCase
  
  include TaliaUtil::TestHelpers
  suppress_fixtures
  
  def setup
    setup_once(:flush) do
      TaliaUtil::Util.flush_db
      TaliaUtil::Util.flush_rdf
      true
    end
    setup_once(:card) do
      source = PiIllustratedMdCard.new(
      :name => "evil guy",
      :code => "codyhoo"
      )
      
      source.save!
      source
    end
    
    assert_not_nil(@card)
  end
  
  def test_create
    card = PiIllustratedMdCard.new
    assert_kind_of(PiIllustratedMdCard, card)
    assert_not_nil(card.uri)
    assert_match(/[^\s]+/, card.uri.to_s)
  end
  
  def test_create_with_save
    assert_nothing_raised { PiIllustratedMdCard.new.save! }
  end
  
  def test_create_with_options
    card = PiIllustratedMdCard.new(:name => "tito", :position => "ups")
    assert_equal("ups", card.position)
    assert_equal("tito", card.name)
  end
  
  def test_name
    assert_equal(@card.name, "evil guy")
  end
  
  def test_code
    assert_equal(@card.code, "codyhoo")
  end
  
  def test_parent_child_relation
    card = PiIllustratedMdCard.new(:name => "tito", :position => "ups")
    parent = PiIllustrationCard.new(:name => 'madre', :position => 'xxx')
    parent.save!
    card.parent_card = parent
    card.save!
    parent = PiIllustrationCard.find(parent.id)
    card = PiIllustratedMdCard.find(card.id)
    assert_kind_of(PiIllustrationCard, card.parent_card)
    assert_equal(parent.uri, card.parent_card.uri)
    assert_equal(1, parent.child_cards.size)
    child = parent.child_cards.first
    assert(!child.new_record?)
    assert_kind_of(PiIllustratedMdCard, child)
    assert_equal(card.uri, child.uri)
  end
  
end