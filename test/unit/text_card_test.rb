require File.dirname(__FILE__) + '/../test_helper'

class TextCardTest < ActiveSupport::TestCase
  
  include TaliaUtil::TestHelpers
  suppress_fixtures
  
  def setup
    setup_once(:flush) do
      TaliaUtil::Util.flush_db
      TaliaUtil::Util.flush_rdf
      true
    end
    
    setup_once(:anastatica) do 
      page = FirbAnastaticaPage.create_page(:title => "meep", :page_positon => "1", :name => "first page")
      page.save!
      page
    end
    
    setup_once(:image_zones) do
      image_zone1 = FirbImageZone.create_with_name('hello')
      image_zone2 = FirbImageZone.create_with_name('heydo')
      image_zone1.save!
      image_zone2.save!
      image_zones = [image_zone1.id, image_zone2.id]
      image_zones
    end
    
    setup_once(:card) do
      source = FirbTextCard.create_card('Title of the card', 'parafrasi pararararrarara', @anastatica.uri.to_s, @image_zones)
      source.save!
      source
    end
    
    assert_not_nil(@card)
    assert_not_nil(@anastatica)
    assert_not_nil(@image_zones)
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