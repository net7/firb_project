class Admin::FirbAnastaticaPagesController < Admin::AdminSiteController

  hobo_model_controller

  auto_actions :all
  
  before_filter :create_zone
  
  def index
    @firb_anastatica_pages = FirbAnastaticaPage.paginate(:page => params[:page], :prefetch_relations => true)
  end
  
  def edit
    @firb_anastatica_page = FirbAnastaticaPage.find(params[:id], :prefetch_relations => true)
  end
  
  def create
    @firb_anastatica_page = FirbAnastaticaPage.create_page(params[:firb_anastatica_page])
    if(@firb_anastatica_page.save!)
      flash[:notice] = "Image #{@firb_anastatica_page.name} succesfully created"
    else
      flash[:notice] = "Error creating the page"
    end
    assign_book_from_params
    delete_books_from_params
    redirect_to :controller => :firb_anastatica_pages, :action => :index
  end
  
  
  def update
    @firb_anastatica_page = FirbAnastaticaPage.find(params[:id], :prefetch_relations => true)
    @firb_anastatica_page.update_attributes!(params[:firb_anastatica_page])
    assign_book_from_params
    delete_books_from_params
    redirect_to :controller => :firb_anastatica_pages, :action => :index
  end
  
  private
  
  def assign_book_from_params
    if(!params[:attach_book].blank? && @firb_anastatica_page.with_acting_user(current_user) { @firb_anastatica_page.update_permitted? })
      uri = N::URI.from_encoded(params[:attach_book])
      book = TaliaCore::Collection.find(uri.to_s)
      book << @firb_anastatica_page
      book.save!
    end
  end
  
  def delete_books_from_params
    if(!params[:delete_books].blank? && @firb_anastatica_page.with_acting_user(current_user) { @firb_anastatica_page.update_permitted? })
      params[:delete_books].each do |id, book_uri|
        book = TaliaCore::Collection.find(id)
        book.delete(@firb_anastatica_page)
        book.save!
      end
    end
  end
  
  def create_zone
    params[:firb_anastatica_page][:image_zone] = params[:firb_anastatica_page][:image_zone].to_uri unless(params[:firb_anastatica_page].blank? || params[:firb_anastatica_page][:image_zone].blank?)
  end
  
end