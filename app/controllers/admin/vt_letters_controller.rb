class Admin::VtLettersController < Admin::AdminSiteController

  hobo_model_controller
  auto_actions :all

  # Because of the silly calendar javascript thing, we need to manually move the date inside
  # the array of params...
  def create
    date = params.delete(:date)
    params[:vt_letter][:date] = date
    file = params[:vt_letter].delete(:file)
    hobo_source_create do |card|
      foo = card.attach_pdf_file(file) if (file)
      flash[:notice] += foo if (foo)
      redirect_to :action => :index
    end
  end

  def update
    date = params.delete(:date)
    params[:vt_letter][:date] = date
    file = params[:vt_letter].delete(:file)
    hobo_source_update do |updated_source|
      updated_source.attach_pdf_file(file) if(file)
      updated_source.save!
      redirect_to :action => :index
    end
  end

end