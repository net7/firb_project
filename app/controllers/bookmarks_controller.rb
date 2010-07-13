class BookmarksController < ApplicationController

  hobo_controller
    
  before_filter :get_user
  before_filter :get_bookmark_collection
  #  skip_before_filter :verify_authenticity_token

  def new
    if logged_in?
      bookmark = TaliaBookmark.create_bookmark(params)
      @collection << bookmark
      @collection.save!
    else
      redirect_to :controller => 'users' #, :action => 'login'
    end
    
  end

  def index
    if logged_in?
      @bookmarks = @collection.elements
      html = render_to_string :index
      data = {'box' => 'Bookmarks'}
      error = 0;
      render :json => {'error' => error,
        'html' => html,
        'data' => data
      }
    else
      html = ''
      data = 'No Logged in'
      error = 30;
      render :json => {'error' => error,
        'html' => html,
        'data' => data
      }

      #TODO not logged in
    end
  end

  

  private

  def get_user
    @user = current_user
    raise(ActiveRecord::RecordNotFound, "No user #{params[:user_name]}") unless(@user)
  end
  
  def get_bookmark_collection
    @collection = BookmarkCollection.new((N::LOCAL + "bookmarks/#{@user.name}").to_uri)
    @collection.save!
  end

  def logged_in?
    !current_user.nil?
  end

end
