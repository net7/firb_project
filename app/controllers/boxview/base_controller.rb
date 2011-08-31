class Boxview::BaseController < ApplicationController
  layout nil
  include ImtHelper
  include BoxviewHelper

  def index; end
end
