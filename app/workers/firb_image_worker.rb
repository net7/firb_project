class FirbImageWorker < Workling::Base
  
  def create_image(options)
    logger.debug("\033[35m\033[4m\033[1mImageWorker\033[0m Begin to process #{options.inspect}")
    image_source = FirbImage.find(options[:image_uri])
    image_source.attach_files(options[:image_file])
    logger.info("\033[35m\033[4m\033[1mImageWorker\033[0m Successfully attached image (#{options.inspect})")
  rescue Exception => e
    logger.error("\033[35m\033[4m\033[1mImageWorker\033[0m Could not attach the image file with #{options.inspect}: #{e.message}")
  end
  
end