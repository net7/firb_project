class ImageWorker < Workling::Base
  
  def create_image(options)
    logger.debug("\033[35m\033[4m\033[1mImageWorker\033[0m Begin to process #{options.inspect}")
    image_source = TaliaCore::ActiveSource.find(options[:image_uri])
    image_source.file_status = "LOADING..."
    image_source.attach_files(:url => options[:image_file], :options => { :mime_type => 'image/jpeg' })
    image_source.file_status = "OK"
    image_source.save!
    logger.info("\033[35m\033[4m\033[1mImageWorker\033[0m Successfully attached image (#{options.inspect})")
  rescue Exception => e
    logger.error("\033[35m\033[4m\033[1mImageWorker\033[0m Could not attach the image file with #{options.inspect}: #{e.message}")
    e.backtrace.each { |msg| logger.debug msg }
    image_source.file_status = "ERROR: #{e.message}"
    image_source.save!
  end
  
end