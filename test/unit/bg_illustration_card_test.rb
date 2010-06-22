require File.dirname(__FILE__) + '/../test_helper'

class BgIllustrationCardTest < ActiveSupport::TestCase

  include TaliaUtil::TestHelpers
  suppress_fixtures

  def setup
    setup_once(:flush) do
      TaliaUtil::Util.flush_db
      TaliaUtil::Util.flush_rdf
      true
    end

    setup_once(:collection) do
      collection = TaliaCore::Collection.new(:title => "collection", :uri => N::LOCAL.barcollection)
      collection.save!
      collection
    end

    setup_once(:card) do
      card = BgIllustrationCard.new("uri"=>"http://localhost:5000/bg_illustration_cards/353194680", "name"=>"nom nom nom", "anastatica"=>"", "image_zone"=>"", "book"=>"", "signature"=>"", "collocation"=>"", "tecnique"=>"", "measure"=>"", "technical_notes"=>"", "edition"=>"", "study_notes"=>"", "motto"=>"", "motto_language"=>"", "motto_translation"=>"", "owner"=>"", "original_meaning"=>"", "contextual_meaning"=>"", "copyright_notes"=>"")
      card.save!
      card
    end

  end

  def test_name
    assert_equal(@card.name, "nom nom nom")
  end

end