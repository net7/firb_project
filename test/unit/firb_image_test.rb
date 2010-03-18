require File.dirname(__FILE__) + '/../test_helper'

class FirbImageTest < ActiveSupport::TestCase
  
  def setup
    @my_image = FirbImage.new
  end
  
  def test_name
    @my_image.name = "testy"
    assert_equal('testy', @my_image.name)
    @my_image.name = "baa"
    assert_equal('baa', @my_image.name)
  end
  
  def test_add_zone
    image = FirbImage.new("http://firbimage/addzone")
    image.add_zone('test2')
    image.add_zone('test')
    image.save!
    assert_equal(['test2', 'test'], image.zones.collect { |z| z.name })
  end

  
end
