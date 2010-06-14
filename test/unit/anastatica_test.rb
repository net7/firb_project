require File.dirname(__FILE__) + '/../test_helper'

class AnastaticaTest < ActiveSupport::TestCase
  
  include TaliaUtil::TestHelpers
  suppress_fixtures
  
  def setup
    setup_once(:flush) do
      TaliaUtil::Util.flush_db
      TaliaUtil::Util.flush_rdf
      true
    end
    setup_once(:page) do
      source = Anastatica.new(:title => "tito", :page_position => "ups")
      source.save!
      source
    end
    setup_once(:page2) do 
      source = Anastatica.new(:title => "chicken", :page_position => "ups") 
      source.save!
      source
    end
    setup_once(:collection_one) do
      collection_one = TaliaCollection.new
      collection_one.uri = 'http://firb_anastatica_test/collection1'
      collection_one.real_source << @page
      collection_one.save!
      collection_one
    end
    setup_once(:collection_two) do
      collection_two = TaliaCollection.new
      collection_two.uri = 'http://firb_anastatica_test/collection2'
      collection_two.save!
      collection_two.real_source << @page2
      collection_two.real_source
      collection_two.real_source.save!
      collection_two
    end
    
    assert_not_nil(@page)
    assert_equal(1, @collection_one.real_source.elements.size)
    assert_equal(2, TaliaCollection.count)
  end
  
  def test_create
    page = Anastatica.new
    assert_kind_of(Anastatica, page)
    assert_not_nil(page.uri)
    assert_match(/[^\s]+/, page.uri.to_s)
  end
  
  def test_create_with_save
    assert_nothing_raised { Anastatica.new.save! }
  end
  
  def test_create_with_options
    page = Anastatica.new(:title => "tito", :page_position => "ups")
    assert_equal("ups", page.page_position)
    assert_equal("tito", page.title)
  end
  
  def test_assigned_books
    assert_equal([@collection_one], @page.attached_to_books)
  end
  
  def test_unattached_books
    assert_equal([@collection_two], @page.unattached_books)
  end
  
  def test_image_zone
    image_zone = ImageZone.create_with_name('foo')
    image_zone.save!
    
    page = Anastatica.new(:title => "tito", :page_position => "ups", :image_zone => image_zone)
    page.save!
    
    assert_equal(image_zone.uri, Anastatica.find(page.id).image_zone.uri)
  end
  
end