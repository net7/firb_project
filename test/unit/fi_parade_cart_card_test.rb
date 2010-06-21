require File.dirname(__FILE__) + '/../test_helper'

class FiParadeCartCardTest < ActiveSupport::TestCase
  
  include TaliaUtil::TestHelpers
  suppress_fixtures
  
  def setup
    setup_once(:flush) do
      TaliaUtil::Util.flush_db
      TaliaUtil::Util.flush_rdf
      true
    end
    
    setup_once(:baldini) do
      baldini = FiTextCard.create_card(:title => "Baldini Text")
      baldini.save!
      baldini
    end
    
    setup_once(:cini) do
      cini = FiTextCard.create_card(:title => "Cini Text")
      cini.save!
      cini
    end
    
    setup_once(:procession) do
      procession = Procession.new(:name => "Sfilata")
      procession.save!
      procession
    end
    
    setup_once(:anastatica) do 
      page = Anastatica.new(:title => "meep", :page_positon => "1", :name => "first page")
      page.save!
      page
    end
    
    setup_once(:cart) do
      cart = FiParadeCartCard.new(
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
      :procession => @procession.uri.to_s,
      :anastatica => @anastatica.uri.to_s,
      :transcription => "Che Carro!",
      :baldini_text => @baldini.uri.to_s,
      :cini_text => @cini,
      :study_notes => 'study',
      :note => { "new.blarg" => "hello world", "new.boo" => "second chance" }
      )
      cart.save!
      cart
    end
    
    @cart.reload
    @procession.reload
    
    assert_not_nil(@cart)
  end
  
  def test_procession
    assert_kind_of(Procession, @cart.procession)
    assert_equal(@cart.procession.uri, @procession.uri)
    assert_equal(@cart.uri, @procession.first.uri)
    assert_equal(1, @procession.size)
  end
  
  def test_for_invalid_procession
    new_cart = FiParadeCartCard.new(:name => "Second", :procession => @procession)
    assert_equal(2, @procession.size)
    assert(!@procession.valid?)
    assert(!new_cart.procession_valid?)
    new_cart.valid?
  end
  
  def test_for_invalid_procession_save
    new_cart = FiParadeCartCard.new(:name => "Second", :procession => @procession.uri.to_s)
    assert(!new_cart.save)
  end
  
  def test_anastatica
    assert_kind_of(Anastatica, @cart.anastatica)
    assert_equal(@anastatica.uri, @cart.anastatica.uri)
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
  
  def test_notes
    assert_equal(2, @cart.notes.size)
    assert_kind_of(Note, @cart.notes.first)
    assert_equal("hello world", @cart.notes.first.content)
  end
  
end