class FirbImageWorker < Workling::Base
  
  def create_image(options)
    image_source = FirbImage.find(options[:image_uri])
    image_source.attach_files(options[:image_file])
  rescue Exception => e
    logger.error("Could not attach the image file with #{options.inspect}: #{e.message}")
  end
  
end