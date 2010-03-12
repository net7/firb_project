class TestWorker < Workling::Base
  
  def do_everything(option)
    logger.info("WAAAAAAAAAAAAAAAAAAAAAAAAAAA did everything")
  end
  
end