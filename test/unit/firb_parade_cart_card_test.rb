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
    
    setup_once(:baldini) do
      baldini = FirbFiTextCard.create_card(:title => "Baldini Text")
      baldini.save!
      baldini
    end
    
    setup_once(:cini) do
      cini = FirbFiTextCard.create_card(:title => "Cini Text")
      cini.save!
      cini
    end
    
    setup_once(:cart) do
      cart = FirbParadeCartCard.new(
      :name => "first_foo",
      :code => "XY Ungelöst",
      :author => "Whoever wins",
      :tecnique => "color",
      :measure => "big",
      :descriptive_notes => "Lala",
      :description => "description",
      # TODO: Vehicle
      # TODO: Deity
      # TODO: THRONE
      :transcription => "Che Carro!",
      :baldini_text => @baldini.uri.to_s,
      :cini_text => @cini,
      :study_notes => 'study',
      :collection => @collection.uri.to_s,
      :parade => @parade.uri.to_s,
      :note => { "new.blarg" => "hello world", "new.boo" => "second chance" }
      )
      cart.save!
      cart = FirbParadeCartCard.find(cart.id)
    end
    
    assert_not_nil(@cart)
  end
  
  def test_name
    assert_equal(@cart.name, "first_foo")
  end
  
  def test_code
    assert_equal(@cart.code, "XY Ungelöst")
  end
  
  def test_author
    assert_equal(@cart.author, "Whoever wins")
  end
  
  def test_tecnique
    assert_equal(@cart.tecnique, "color")
  end
  
  def test_measure
    assert_equal(@cart.measure, "big")
  end
  
  def test_descriptive_notes
    assert_equal(@cart.descriptive_notes, "Lala")
  end
  
  def test_description
    assert_equal(@cart.description, "description")
  end
  
  def test_transcription
    assert_equal(@cart.transcription, "Che Carro!")
  end
  
  def test_baldini_text
    assert_equal(@cart.baldini_text.name, "Baldini Text")
  end
  
  def test_cini_text
    assert_equal(@cart.cini_text.name, "Cini Text")
  end
  
  def test_study_notes
    assert_equal(@cart.study_notes, 'study')
  end
  
  def test_collection
    @collection.reload
    collection = TaliaCore::ActiveSource.find(@collection.id)
    assert_equal(collection.first.uri, @cart.uri)
    assert_equal(@cart.collection.uri, collection.uri)
  end
  
  def test_parade
    @parade.reload
    parade = Parade.find(@parade.id)
    assert_equal(parade.first.uri, @cart.uri)
    assert_equal(@cart.parade.uri, @parade.uri)
  end
  
  def test_notes
    assert_equal(2, @cart.notes.size)
    assert_kind_of(FirbNote, @cart.notes.first)
    assert_equal("hello world", @cart.notes.first.content)
  end
  
end