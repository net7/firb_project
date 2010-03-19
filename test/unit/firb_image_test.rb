require File.dirname(__FILE__) + '/../test_helper'
require 'fileutils'
class FirbImageTest < ActiveSupport::TestCase
  
  def setup
    flush_rdf
    @my_image = FirbImage.new("http://default-firb.com/image")
    @test_file_name = File.join(TALIA_CODE_ROOT, 'test', 'fixtures', 'tiny.jpg')
  end
  
  def test_name
    @my_image.name = "testy"
    assert_equal('testy', @my_image.name)
    @my_image.name = "baa"
    assert_equal('baa', @my_image.name)
  end
  
  def test_add_zone
    image = FirbImage.new("http://firbimage/addzone")
    assert(image.zones.empty?)
    image.add_zone('test2')
    image.add_zone('test')
    image.save!
    assert_equal(2, image.zones.size)
    assert_equal(['test2', 'test'], image.zones.collect { |z| z.name })
  end

  def test_attach_file
    image = FirbImage.new("http://firbimage/addzone")
    image.attach_file(@test_file_name)
    image.save!
    wait_for_attach(image)
    assert_equal(1, image.data_records.size)
    assert_kind_of(TaliaCore::DataTypes::ImageData, image.data_records.first)
  end
  
  def test_attach_tempfile
    image = FirbImage.new("http://firbimage/addzone_temp")
    tmpfile = Tempfile.open((rand Time.now.to_i).to_s) do |tf|
      File.open(@test_file_name) { |test| tf << test.read }
      image.attach_file(tf)
      image.save!
      wait_for_attach(image)
      assert_equal(1, image.data_records.size)
      assert_kind_of(TaliaCore::DataTypes::ImageData, image.data_records.first)
    end
  end
  
  private
  
  def wait_for_attach(image)
    start_time = Time.now
    while(image.data_records.empty?)
      sleep 0.5
      if((Time.now - start_time) > 10)
        flunk("Timeout waiting for image to attach")
        break
      end
    end
  end
  
end
