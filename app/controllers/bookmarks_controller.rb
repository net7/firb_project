class BookmarksController < ApplicationController
  hobo_controller

  before_filter :basic_auth
  before_filter :get_talia_user
  before_filter :get_bookmark_collection
  #  skip_before_filter :verify_authenticity_token

  # TODO: make a stub for the collection, which contains:
  # - my (which are notebooks)
  # - subscribed  (which are notebooks)
  # Each notebook shows:
  # - uri, public (T/F), author (email or talia user?), note, title, subscribers, bookmarks
  # Each bookmark shows:
  # - uri, title, author(? or just NB author?) qstring, type, date

  def stub
    bm11 = {'uri' => 'http://something1/', 
            'title' => 'MARMI, 1552-1553, I, p. 1', 
            'qstring' => 'boxViewer.php?method=getTranscription&lang=it&contexts=marmi1552&resource=eHBiMDAwMDAx',
            'resourceType' => 'transcription',
            'date' => 'oggi' }
    bm12 = {'uri' => 'http://something2/', 
            'title' => 'MARMI, 1552-1553, I, p. 1', 
            'qstring' => 'boxViewer.php?method=getImageInfo&lang=it&contexts=marmi1552&resource=eG1sOi8vYWZkL21hcm1pMTU1Ml9pbWcvcDAwMXB0MDAxcGcwMDE=',
            'resourceType' => 'imageInfo',
            'date' => 'ieri sul presto' }
    bm22 = {'uri' => 'http://something2/', 
            'title' => 'MARMI, 1552-1553, I, p. 1', 
            'qstring' => 'boxViewer.php?method=getImageInfo&lang=it&contexts=marmi1552&resource=eG1sOi8vYWZkL21hcm1pMTU1Ml9pbWcvcDAwMXB0MDAxcGcwMDE=',
            'resourceType' => 'imageInfo',
            'date' => 'ieri l\'altro' }
    nb1 = {'uri' => 'http://notebook1url/',
            'public' => true,
            'author' => 'Simone Fonda',
            'note' => 'Not a book note book not ebook notebook',
            'title' => 'Not a book',
            'subscribers' => 30341,
            'bookmarks' => [bm11, bm12]}
    nb2 = {'uri' => 'http://notebook2url/',
            'public' => true,
            'author' => 'Michele Barbera',
            'note' => 'Out of town very important conference notebook',
            'title' => 'Out of town notebook',
            'subscribers' => 21,
            'bookmarks' => [bm22]}
    nb3 = {'uri' => 'http://notebook2url/',
            'public' => true,
            'author' => 'Danilo Giacomi',
            'note' => 'Super secret notebook',
            'title' => 'Empty notebook, but secret',
            'subscribers' => 21,
            'bookmarks' => []}
    html = {}
#    {'error' => '0', 'data' => {'prefs' => {}, 
#                                'notebooks' => {'my' => [nb1], 'subscribed' => [nb2]},
#                                'login_panel_html' => html}
#    }
    {'error' => '0', 'data' => {'prefs' => {'name' => @user.name, 
                                            'resizemeImagesMaxWidth' => '600', 
                                            'animations' => 1,
                                            'useCookie' => true}, 
                                'notebooks' => [nb1]+[nb2]},
                                'login_panel_html' => html
    }
    

  end


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
    # TODO: created a stub to get a legal result out of this
    #data = []
    #@collection.elements.each do |b|
    #  data << { 'title' => b.title,
    #      'qstring' => b.qstring, 'date' => b.date, 'note' => b.notes,
    #      'resource_type' => b.resource_type, 'uri' => b.uri.to_s, 'public' => b.public}
    #end
    #result = {'error' => '0', 'data' => data}
    # render :json => result
    render :json => stub
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

  # TODO: is this called at all? Dont we get a basic auth error if we're not logged in? 
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

   def get_talia_user
    @talia_user = TaliaUser.find_by_name_and_email(@user.name, @user.email_address)
    raise(ActiveRecord::RecordNotFound, "No user #{params[:user_name]}") unless(@talia_user)
  end
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
