require File.dirname(__FILE__) + '/../test_helper'

class PiTextCardTest < ActiveSupport::TestCase
  
  include TaliaUtil::TestHelpers
  suppress_fixtures
  
  def setup
    setup_once(:flush) do
      TaliaUtil::Util.flush_db
      TaliaUtil::Util.flush_rdf
      true
    end
    
    setup_once(:anastatica) do 
      page = Anastatica.new(:title => "meep", :page_positon => "1", :name => "first page")
      page.save!
      page
    end
    
    setup_once(:image_zones) do
      image_zone1 = FirbImageZone.create_with_name('hello')
      image_zone2 = FirbImageZone.create_with_name('heydo')
      image_zone1.save!
      image_zone2.save!
      image_zones = [image_zone1.uri.to_s, image_zone2.uri.to_s]
      image_zones
    end
    
    setup_once(:non_illustrated) do
      (1..2).collect do |idx|
        card = FirbNonIllustratedMemoryDepictionCard.new(:name => "FOO#{idx}")
        card.save!
        { :uri => card.uri.to_s }
      end
    end
    
    setup_once(:card) do
      source = FirbPiTextCard.create_card(:title => 'Title of the card', :parafrasi => 'parafrasi pararararrarara', :anastatica => @anastatica.uri.to_s, :image_zones => @image_zones, :non_illustrated_memory_depictions => @non_illustrated)
      source.save!
      source
    end
    
    assert_not_nil(@card)
    assert_not_nil(@anastatica)
    assert_not_nil(@image_zones)
    assert_not_nil(@non_illustrated)
  end
  
  def test_non_illustrated
    assert_equal(2, @card.non_illustrated_memory_depictions.size)
  end
  
  def test_create_components
    assert_difference("FirbNonIllustratedMemoryDepictionCard.count", 1) do
      card = FirbPiTextCard.create_card(:title => 'Title of the card', :parafrasi => 'parafrasi pararararrarara', :anastatica => @anastatica.uri.to_s, :image_zones => @image_zones, :non_illustrated_memory_depictions => [:uri => "", :title => "Noobar"])
      card.save!
    end
  end
  
  def test_title
    assert_equal('Title of the card', @card.title)
  end
  
  def test_parafrasi
    assert_equal('parafrasi pararararrarara', @card.parafrasi)
  end
  
  def test_anastatica
    assert_equal(@anastatica.uri, @card.anastatica.uri)
  end
  
  def test_image_zone
    assert_equal(['hello', 'heydo'], @card.image_zones.collect { |z| z.name })
  end
end