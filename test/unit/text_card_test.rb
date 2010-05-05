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
    
    setup_once(:image_zone) do
      image_zone = FirbImageZone.create_with_name('hello')
      image_zone.save!
      image_zone
    end
    
    
    setup_once(:card) do
      source = FirbTextCard.create_card('rollollolllo', @anastatica.uri.to_s, @image_zone.uri.to_s)
      source.save!
      source
    end
    
    assert_not_nil(@card)
    assert_not_nil(@anastatica)
    assert_not_nil(@image_zone)
  end
  
  def test_parafrasi
    assert_equal('rollollolllo', @card.parafrasi)
  end
  
  def test_anastatica
    assert_equal(@anastatica.uri, @card.anastatica.uri)
  end
  
  def test_image_zone
    assert_equal(@image_zone.uri, @card.image_zone.uri)
  end
end