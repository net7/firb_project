require File.dirname(__FILE__) + '/../test_helper'

class FirbParadeCartCardTest < ActiveSupport::TestCase

  include TaliaUtil::TestHelpers
  suppress_fixtures

  def setup
    setup_once(:flush) do
      TaliaUtil::Util.flush_db
      TaliaUtil::Util.flush_rdf
      true
    end

    setup_once(:parade) do
      parade = Parade.new(:title => "Sfilata")
      parade.save!
      parade 
    end

    setup_once(:collection) do
      collection = TaliaCore::Collection.new(:title => "collection", :uri => N::LOCAL.barcollection)
      collection.save!
      collection
    end
  end

  def test_char_qualities
    card = FirbParadeCharacterCard.new(:character_qualities => "Boing")
    card.save!
    card.reload
    assert_equal(card.character_qualities, "Boing")
  end

end