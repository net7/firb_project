require File.dirname(__FILE__) + '/../test_helper'
require 'fileutils'
class FirbImageTest < ActiveSupport::TestCase
  
  def setup
    flush_rdf
    @my_image = FirbImage.new("http://default-firb.com/image")
    @test_file_name = '/Users/daniel/Pictures/bloom-steve-giraffe-8300182.jpg' # File.join(TALIA_CODE_ROOT, 'test', 'fixtures', 'tiny.jpg')
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

  def test_file_status
    assert_equal(nil, @my_image.file_status)
  end

  def test_attach_file
    image = FirbImage.new("http://firbimage/addzone")
    image.attach_file(@test_file_name)
    image.save!
    wait_for_attach(image)
    recs = image.data_records.reject { |r| r.kind_of?(TaliaCore::DataTypes::ImageData) }
    assert_equal(1, recs.size)
    assert_equal("OK", image.file_status)
  end
  
  def test_attach_tempfile
    image = FirbImage.new("http://firbimage/addzone_temp")
    tmpfile = Tempfile.open((rand Time.now.to_i).to_s) do |tf|
      File.open(@test_file_name) { |test| tf << test.read }
      image.attach_file(tf)
      image.save!
      wait_for_attach(image)
      recs = image.data_records.reject { |r| r.kind_of?(TaliaCore::DataTypes::ImageData) }
      assert_equal(1, recs.size)
      assert_equal("OK", image.file_status)
    end
  end
  
  private
  
  def wait_for_attach(image)
    start_time = Time.now
    while(image.data_records.empty?)
      if((Time.now - start_time) > 10)
        flunk("Timeout waiting for image to attach")
        break
      end
    end
  end
  
end
