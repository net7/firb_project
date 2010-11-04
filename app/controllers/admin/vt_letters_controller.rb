class Admin::VtLettersController < Admin::AdminSiteController

  hobo_model_controller
  auto_actions :all

  # Because of the silly calendar javascript thing, we need to manually move the date inside
  # the array of params...
  def create
    date = params.delete(:date)
    params[:vt_letter][:date] = date
    hobo_source_create
  end

  def update
    date = params.delete(:date)
    params[:vt_letter][:date] = date
    hobo_source_update
  end

end