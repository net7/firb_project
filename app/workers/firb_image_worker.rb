class FirbImageWorker < Workling::Base
  
  def create_image(options)
    logger.debug("\033[35m\033[4m\033[1mImageWorker\033[0m Begin to process #{options.inspect}")
    puts "\n\n\ BEGIN WORKER \n\n\n"
    image_source = FirbImage.find(options[:image_uri])
    image_source.attach_files(:url => options[:image_file], :options => { :mime_type => 'image/jpeg' })
    image_source.file_status = "OK"
    image_source.save!
    logger.info("\033[35m\033[4m\033[1mImageWorker\033[0m Successfully attached image (#{options.inspect})")
    puts "\n\n\ FINISH WORKER \n\n\n"
  rescue Exception => e
    puts "\n\n\ WORKER ERROR #{e.message} \n\n\n"
    puts e.backtrace
    logger.error("\033[35m\033[4m\033[1mImageWorker\033[0m Could not attach the image file with #{options.inspect}: #{e.message}")
    e.backtrace.each { |msg| logger.debug msg }
    image_source.file_status = "ERROR: #{e.message}"
    image_source.save!
  end
  
end