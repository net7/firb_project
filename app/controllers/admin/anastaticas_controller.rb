class Admin::AnastaticasController < Admin::AdminSiteController

  hobo_model_controller

  auto_actions :all
  
  before_filter :create_zone
  
  def index
    @anastaticas = Anastatica.paginate(:page => params[:page], :prefetch_relations => true)
  end
  
  def edit
    @anastatica = Anastatica.find(params[:id], :prefetch_relations => true)
  end
  
  def create
    hobo_source_create do
      assign_book_from_params
      delete_books_from_params
      redirect_to :controller => :anastaticas, :action => :index
    end
  end
  
  
  def update
    hobo_source_update(:find_options => { :prefetch_relations => true }) do
      assign_book_from_params
      delete_books_from_params
      redirect_to :controller => :anastaticas, :action => :index
    end
  end
  
  private
  
  def assign_book_from_params
    if(!params[:attach_book].blank? && @anastatica.updatable_by?(current_user))
      uri = N::URI.from_encoded(params[:attach_book])
      book = TaliaCore::Collection.find(uri.to_s)
      book << @anastatica
      book.save!
    end
  end
  
  def delete_books_from_params
    if(!params[:delete_books].blank? && @anastatica.updatable_by?(current_user))
      params[:delete_books].each do |id, book_uri|
        book = TaliaCore::Collection.find(id)
        book.delete(@anastatica)
        book.save!
      end
    end
  end
  
  def create_zone
    params[:anastatica][:image_zone] = params[:anastatica][:image_zone].to_uri unless(params[:anastatica].blank? || params[:anastatica][:image_zone].blank?)
  end
  
end