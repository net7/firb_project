class BookmarksController < ApplicationController
  hobo_controller

#  before_filter :get_user
  before_filter :basic_auth
  before_filter :get_bookmark_collection
  #  skip_before_filter :verify_authenticity_token

  # Create a new bookmark and add it to the user collection
  def new
    #    if logged_in?
    bookmark = TaliaBookmark.create_bookmark(params)
    @collection << bookmark
    @collection.save!
    html = bookmark.uri
    data = {}
    error = 0;
    render_json(html, data, error)
    #    else
    #      redirect_to :controller => 'users' #, :action => 'login'
    #    end
  end

  # Return a list of bookmarks with all their data
  def index
    #    if logged_in?
    @bookmarks = @collection.elements
    respond_to do |format|
      format.json {render_json_index}
      format.html {render_html_index}
    end
    #    else
    #      render_not_logged_in_json
    #    end
  end

  def render_html_index
    html = render_to_string "bookmark/index"
    data = {'box' => 'Bookmarks'}
    error = 0;
    render_json(html, data, error)

  end

  def render_json_index
    data = []
    @collection.elements.each do |b|
      data << {'title' => b.title,
          'qstring' => b.qstring, 'date' => b.date, 'note' => b.notes,
          'resource_type' => b.resource_type, 'uri' => b.uri.to_s, 'public' => b.public}
    end
    result = ['error' => '0', 'data' => data]
    render :json => result
  end

  def delete
#    if logged_in?
      @collection.remove_bookmark(params[:bookmark_uri])
      html = 'deleted'
      data = {}
      error = 0
      render_json(html, data, error)
#    else
#      render_not_logged_in_json
#    end
  end

  # We update just the notes and the public fields
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

  #  Proper user control, based on hobo users
  #
  #   def get_user
  #    @user = current_user
  #    raise(ActiveRecord::RecordNotFound, "No user #{params[:user_name]}") unless(@user)
  #  end
  #
  #  def get_bookmark_collection
  #    if logged_in?
  #      @collection = BookmarkCollection.new((N::LOCAL + "bookmarks/#{@user.name}").to_uri)
  #      @collection.save!
  #    end
  #  end
  #
  #  def logged_in?
  #    return true unless (current_user.instance_of? Guest)
  #  end


#  def get_user
#    @user = User.find_by_name(params[:user_name])
#    #    raise(ActiveRecord::RecordNotFound, "No user #{params[:user_name]}") unless(@user)
#    render_not_logged_in_json unless(@user)
#  end

  def get_bookmark_collection
    @collection = BookmarkCollection.new((N::LOCAL + "bookmarks/#{@user.name}").to_uri)
    @collection.save!
  end

  def basic_auth
#    user_email = @user.email_address
    authenticate_or_request_with_http_basic("Bookmarks") do |user, pass|
      @user = User.authenticate(user, pass) #if(@user.name == user)
    end
  end
end
