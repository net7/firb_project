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
      page = FirbAnastaticaPage.new(:title => "meep", :page_positon => "1", :name => "first page")
      page.save!
      page
    end
    
    setup_once(:bibliographies) do
      bibliographies = []
      (0..2).each do |idx|
        bibliography = BibliographyItem.new(:title => "bib_#{idx}")
        bibliography.save!
        bibliographies << bibliography
      end
      bibliographies
    end
    
    assert_equal(3, @bibliographies.size)
    
    setup_once(:card) do
      source = FirbCard.new(
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
      :anastatica => @page.uri,
      :bibliography_items => @bibliographies.collect { |bib| bib.uri.to_s }
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
    card = FirbCard.new
    assert_kind_of(FirbCard, card)
    assert_not_nil(card.uri)
    assert_match(/[^\s]+/, card.uri.to_s)
  end

  def test_bibliographies
    assert_property(@card.bibliography_items, *@bibliographies)
  end
  
  def test_create_with_save
    assert_nothing_raised { FirbCard.new.save! }
  end
  
  def test_create_with_options
    card = FirbCard.new(:name => "tito", :position => "ups")
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
  
  def test_rewrite_attributes
    source = FirbCard.new(
    :name => "evil guy"
    )
    source.save!
    new_find = FirbCard.find(source.id)
    new_find.rewrite_attributes!(:name => "barf",
    :anastatica => @page.uri,
    :bibliography_items => @bibliographies.collect { |bib| bib.uri.to_s })
    new_card = FirbCard.find(source.id)
    assert_equal('barf', new_card.name)
    assert_equal(new_card.anastatica.uri, @page.uri)
    assert_equal(3, new_card.bibliography_items.size)
  end
  
end