require File.dirname(__FILE__) + '/../test_helper'

class ImageComponentTest < ActiveSupport::TestCase
  
  include TaliaUtil::TestHelpers
  suppress_fixtures
  
  def setup
    setup_once(:flush) do
      TaliaUtil::Util.flush_db
      TaliaUtil::Util.flush_rdf
      true
    end
    setup_once(:image_zone) do
      image_zone = ImageZone.create_with_name("zony")
      image_zone.save!
      image_zone
    end

    setup_once(:image_component) do
      image_component = ImageComponent.new(:name => 'nomy', :zone_type => 'xxx', :image_zone => @image_zone.uri.to_s)
      image_component.save!
      image_component
    end

    @image_component = ImageComponent.find(@image_component.id)

    assert_not_nil(@image_component)
  end
  
  def test_name
    assert_equal('nomy', @image_component.name)
  end
  
  def test_zone_type
    assert_equal('xxx', @image_component.zone_type)
  end
  
  def test_image_zone
    assert_kind_of(ImageZone, @image_component.image_zone)
    assert_equal(@image_component.image_zone.uri, @image_zone.uri)
  end
  
end