class BookmarksController < ApplicationController

  hobo_controller
    
  before_filter :get_user
  before_filter :get_bookmark_collection
  #  skip_before_filter :verify_authenticity_token

  # Create a new bookmark and add it to the user collection
  def new
    if logged_in?
      bookmark = TaliaBookmark.create_bookmark(params)
      @collection << bookmark
      @collection.save!
      html = bookmark.uri
      data = {}
      error = 0;
      render_json(html, data, error)
    else
      redirect_to :controller => 'users' #, :action => 'login'
    end  
  end

  # Return a list of bookmarks with all their data
  def index
    if logged_in?
      @bookmarks = @collection.elements
      html = render_to_string "bookmark/index"
      data = {'box' => 'Bookmarks'}
      error = 0;
      render_json(html, data, error)
    else
      render_not_logged_in_json
    end
  end

  def delete
    if logged_in?
      @collection.remove_bookmark(params[:bookmark_uri])
      html = 'deleted'
      data = {}
      error = 0
      render_json(html, data, error)
    else
      render_not_logged_in_json
    end
  end

  # We update just the notes
  def update
    if logged_in?
      # TODO: all
    end
  end

  def render_json(html, data, error)
    render :json => {'error' => error,
      'html' => html,
      'data' => data
    }
  end

  def render_not_logged_in_json
    html = 'Not Logged in'
    data = 'Not Logged in'
    error = 30;
    render :json => {'error' => error,
      'html' => html,
      'data' => data
    }
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
