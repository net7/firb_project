require File.dirname(__FILE__) + '/../test_helper'

class FirbCardTest < ActiveSupport::TestCase
  
  include TaliaUtil::TestHelpers
  suppress_fixtures
  
  def setup
    setup_once(:flush) do
      TaliaUtil::Util.flush_db
      TaliaUtil::Util.flush_rdf
      true
    end
    
    setup_once(:page) do 
      page = FirbAnastaticaPage.create_page(:title => "meep", :page_positon => "1", :name => "first page")
      page.save!
      page
    end
    
    setup_once(:card) do
      source = FirbCard.create_card(
      :name => "evil guy",
      :code => "codyhoo", 
      :collocation => "wassup, man?",
      :tecnique => "fine lining",
      :measure => "big times big",
      :position => "first in line",
      :descriptive_notes => 'An evil guy killing the dragon',
      :study_notes => 'What a pain',
      :description => 'Endangered species',
      :completed => 'true',
      :anastatica => @page.uri
      )
      
      source.save!
      source
    end
    
    assert_not_nil(@card)
    assert_not_nil(@page)
  end
  
  ############ TODO
  # Anastatica page it links to
  # singular_property :anastatica, N::DCT.isPartOf

  # Image zone this illustration is in
  # singular_property :image_zone, N::DCT.isFormatOf

  def test_anastatica
    assert_kind_of(FirbAnastaticaPage, @card.anastatica)
    assert_equal(@card.anastatica.uri, @page.uri)
  end
  
  def test_create
    card = FirbCard.create_card
    assert_kind_of(FirbCard, card)
    assert_not_nil(card.uri)
    assert_match(/[^\s]+/, card.uri.to_s)
  end
  
  def test_create_with_save
    assert_nothing_raised { FirbCard.create_card.save! }
  end
  
  def test_create_with_options
    card = FirbCard.create_card(:name => "tito", :position => "ups")
    assert_equal("ups", card.position)
    assert_equal("tito", card.name)
  end
  
  def test_name
    assert_equal(@card.name, "evil guy")
  end
  
  def test_code
    assert_equal(@card.code, "codyhoo")
  end
  
  def test_collocation
    assert_equal(@card.collocation, "wassup, man?")
  end
  
  def test_tecnique
    assert_equal(@card.tecnique, "fine lining")
  end
  
  def test_measure
    assert_equal(@card.measure, "big times big")
  end
  
  def test_position
    assert_equal(@card.position, "first in line")
  end
  
  def test_descriptive_notes
    assert_equal(@card.descriptive_notes, 'An evil guy killing the dragon')
  end
  
  def test_study_notes
    assert_equal(@card.study_notes, 'What a pain')
  end
  
  def test_description
    assert_equal(@card.description, 'Endangered species')
  end
  
  def test_completed
    assert_equal(@card.completed, 'true')
  end
  
end