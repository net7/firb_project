require File.dirname(__FILE__) + '/../test_helper'
require 'fileutils'

class FirbImageTest < ActiveSupport::TestCase
  
  def setup
    flush_rdf
    @my_image = FirbImage.new("http://default-firb.com/image")
    @test_file_name = File.join(TALIA_CODE_ROOT, 'test', 'fixtures', 'tiny.jpg')
    TaliaCore::CONFIG['iip_root_directory_location'] = File.join(TALIA_CODE_ROOT, 'test', 'tmp_iip_root')
    FileUtils.rm_rf(TaliaCore::CONFIG['iip_root_directory_location'])
  end
  
  def teardown
    FileUtils.rm_rf(TaliaCore::CONFIG['iip_root_directory_location'])
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

  def test_destroy
    image = FirbImage.new("http://firbimage/addzone")
    assert(image.zones.empty?)
    image.add_zone('testabc')
    image.add_zone('testabcd')
    image.add_zone('testabcde')
    image.save!
    assert_equal(3, image.zones.size)
    ids = image.zones.collect{|z| z.id }
    assert_difference("TaliaCore::ActiveSource.count", -4) do
      image.destroy
    end
    # image.destroy
    # ids.each{|id| assert(!TaliaCore::ActiveSource.exist?(id))}
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
    tmpfile = 'nil'
    Tempfile.open((rand Time.now.to_i).to_s) do |tf|
      File.open(@test_file_name) { |test| tf << test.read }
      tmpfile = tf.path
    end
    File.open(tmpfile) do |tf|
      image.attach_file(tf)
      image.save!
      wait_for_attach(image)
      recs = image.data_records.reject { |r| r.kind_of?(TaliaCore::DataTypes::ImageData) }
      assert_equal(1, recs.size)
      assert_equal("OK", image.file_status)
    end
  end
  
  def test_thumb_and_orig
    image = FirbImage.new("http://firbimage/thumb_and_orig")
    image.attach_file(@test_file_name)
    image.save!
    wait_for_attach(image)
    assert_kind_of(TaliaCore::DataTypes::IipData, image.iip_record)
    assert_kind_of(TaliaCore::DataTypes::ImageData, image.original_image)
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
