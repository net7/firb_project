require "base64"
class BookmarksController < ApplicationController
  hobo_controller

  before_filter :basic_auth
  before_filter :get_talia_user
  before_filter :get_bookmark_collections
  #  skip_before_filter :verify_authenticity_token

  # TODO: make a stub for the collection, which contains:
  # - my (which are notebooks)
  # - subscribed  (which are notebooks)
  # Each notebook shows:
  # - uri, public (T/F), author (email or talia user?), note, title, subscribers, bookmarks
  # Each bookmark shows:
  # - uri, title, author(? or just NB author?) qstring, type, date
  # Give this both as json and as html inside the login action (/index)

  def stub
    @bm11 = {'uri' => 'http://something1/', 
      'title' => 'MARMI, 1552-1553, I, p. 1',
      'qstring' => 'boxViewer.php?method=getTranscription&lang=it&contexts=marmi1552&resource=eHBiMDAwMDAx',
      'note' => 'Mamma mia che bella questa trascrizione.. wunderbar',
      'resourceType' => 'transcription',
      'date' => 'oggi' }
    @bm12 = {'uri' => 'http://something2/', 
      'title' => 'MARMI, 1552-1553, I, p. 1',
      'qstring' => 'boxViewer.php?method=getImageInfo&lang=it&contexts=marmi1552&resource=eG1sOi8vYWZkL21hcm1pMTU1Ml9pbWcvcDAwMXB0MDAxcGcwMDE=',
      'resourceType' => 'imageInfo',
      'note' => 'Nota piccina, corta corta',
      'date' => 'ieri sul presto' }
    @bm22 = {'uri' => 'http://something2/', 
      'title' => 'MARMI, 1552-1553, I, p. 1',
      'qstring' => 'boxViewer.php?method=getImageInfo&lang=it&contexts=marmi1552&resource=eG1sOi8vYWZkL21hcm1pMTU1Ml9pbWcvcDAwMXB0MDAxcGcwMDE=',
      'resourceType' => 'imageInfo',
      'note' => 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
      'date' => 'ieri l\'altro' }
    @nb1 = {'uri' => 'http://notebook1url/',
      'public' => true,
      'author' => 'Simone Fonda',
      'note' => 'Not a book note book not ebook notebook',
      'title' => 'Not a book',
      'subscribers' => 30341,
      'bookmarks' => [@bm11, @bm12]}
    @nb2 = {'uri' => 'http://notebook2url/',
      'public' => true,
      'author' => 'Michele Barbera',
      'note' => 'Out of town very important conference notebook',
      'title' => 'Out of town notebook',
      'subscribers' => 21,
      'bookmarks' => [@bm22]}
    @nb3 = {'uri' => 'http://notebook2url/',
      'public' => true,
      'author' => 'Danilo Giacomi',
      'note' => 'Super secret notebook',
      'title' => 'Empty notebook, but secret',
      'subscribers' => 21,
      'bookmarks' => []}
    
  end

  # Returns the form for the frontend's new/modify dialog
  def get_bookmark_dialog

    #      foo = stub
    load_notebooks_vars

    # TODO: move this html to a view or another partial ..
    html = "<div class='dialog_accordion'>"

    # Insert the standard 'new' bookmark part
    bm = {:qstring => params[:qstring], :title => params[:title], :resourceType => params[:resourceType], :resourceTypeString => params[:resourceTypeString]}
      
    html += render_to_string :partial => '/bookmark/bookmark_new_dialog.html', :locals => { :bm => bm }

    # Use my notebooks to render the edit forms
    # TODO: need to filter @my_notebooks to get out only those having a bm which refers to params[:qstring]
    # FIXME: uncomment this as soon as edit_dialog gets needed
    #html += render_to_string :partial => '/bookmark/bookmark_edit_dialog.html', :locals => { :my => [@my_notebooks]} unless @my_notebooks.empty?
    
    # TODO: remove this html as before
    html += "</div>"

    error = 0
    data = {:error => error, :html => html}
    render_json(html, data, error)
  end

  # Returns an entire box with all of its notebook's widgets
  def get_notebook_box
    # TODO: for what notebook? All of em? set @some_notebook
    # html = render_to_string :partial => '/bookmark/notebook_widget.html', :object => @some_notebook
    error = 0
    data = {:error => error, :box => @some_notebook.title, :html => html}
    render_json(html, data, error)
  end

  # Returns a widget to be inserted at the top of a content box, with all the notebooks which
  # contains the given qstring in one of its bookmarks. The notebooks will contain only the 
  # bookmarks of the given qstring
  def get_my_doni_widget
    #      foo = stub
    load_notebooks_vars
    qstring = params[:qstring]
    # TODO : replace nb1 and nb2 with arrays with owned and subscribed notebooks which
    # contains the given qstring
    # html = render_to_string :partial => '/bookmark/my_doni_widget.html'#, :locals => { :my => [@nb2], :subscribed => [@nb1, @nb3]}
    html = render_to_string :partial => '/bookmark/my_doni_widget.html', :locals => { :my => @my_notebooks, :subscribed => @subscribed_notebooks}
    error = 0
    data = {:error => error, :html => html}
    render_json(html, data, error)
  end


  # Create a new bookmark and add it to the specified notebook
  # the form should pass, amongst other things, the notebook uri to which
  # the bookmark has to be added (:notebook)
  def new_bookmark
    notebook_uri = params.delete(:notebook)
    bookmark = TaliaBookmark.create_bookmark(params)
    notebook = BookmarkCollection.find(notebook_uri)
    notebook.add_bookmark(bookmark)
    html = bookmark.uri
    data = {}
    error = 0;
    render_json(html, data, error)
  end

  # creates a new notebook
  def new_notebook
    puts "------------- " + params.inspect
    notebook = BookmarkCollection.create_bookmark_collection(params)
    notebook.set_owner(@talia_user)
    notebook.save!
    html = notebook.uri
    data = {}
    error = 0;
    render_json(html, data, error)
  end

  def follow_notebook
    notebook = BookmarkCollection.find(params.delete(:notebook))
    raise if notebook.nil? or !notebook.is_a? BookmarkCollection
    add_follower(@talia_user)
  end

  # Return a list of bookmarks with all their data
  def index
    #    if logged_in?
    #     @bookmarks = @collection.elements

    load_notebooks_vars

    respond_to do |format|
      format.json {render_json_index}
      format.html {render_html_index}
    end
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
    #
    #result = {'error' => '0', 'data' => data}
    # render :json => result

    # TODO: delete this stub and get the real data from rdf, replace @nb1-2-3 with real stuff,
    # keeping them into an array.
    #    foo = stub
    load_notebooks_vars

    # html = render_to_string :partial => '/bookmark/my_doni_index.html' #, :locals => { :my => [@nb1]+@my_notebooks, :subscribed => [@nb2, @nb3]}
    html = render_to_string :partial => '/bookmark/my_doni_index.html', :locals => { :my => @my_notebooks, :subscribed => @subscribed_notebooks }

    puts "@@@@@@@@@@@@@@@@@@@@@@@@@"
    puts @my_notebooks.inspect + @subscribed_notebooks.inspect
    puts "@@@@@@@@@@@@@@@@@@@@@@@@@"

    # TODO: any idea on how to craft a json like this in a better way? Like some
    # helper .. dunno

    # prefs: contains the preference object got from the frontend on a
    #        preference save action
    # notebooks: contains all the notebooks this user is subscribed to/owner of
    # login_panel_html: html code for the my doni box

    notebooks = []
    @my_notebooks.each{|n| notebooks << jsonify_notebook(n)}
    @subscribed_notebooks.each{|n| notebooks << jsonify_notebook(n)}
    
    json = { 'error' => '0', 
      'data' => {'prefs' => {'name' => @user.name,
          'resizemeImagesMaxWidth' => '600',
          'animations' => 1,
          'useCookie' => true},
        #                        'notebooks' => [@nb1]+[@nb2],
        'notebooks' => notebooks,
        'my_doni_html' => html
      }
    }
    
    render :json => json
  end

  def delete
    collection_uri = params.delete(:notebook)
    collection = BookmarkColletion.find(collection_uri)
    #TODO return error if collection not owned by current user
    collection.remove_bookmark(params[:bookmark_uri])
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

  
  def render_invalid_user_and_pass_json
    html = 'Invalid User and Password'
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
    render_invalid_user_and_pass_json unless(@talia_user)
  end

  # Returns the list of notebooks of the active @talia_user
  def get_user_notebooks
    qry = ActiveRDF::Query.new(BookmarkCollection).select(:bc).distinct
    qry.where(:bc, N::TALIA.owner, @talia_user)
    qry.execute
  end


  def load_notebooks_vars
    @my_notebooks = get_user_notebooks || []
    @subscribed_notebooks = get_subscribed_notebooks || []
  end

  # Returns the list of notebooks the active @talia_user is following
  def get_subscribed_notebooks
    qry = ActiveRDF::Query.new(BookmarkCollection).select(:bc).distinct
    qry.where(@talia_user, N::TALIA.follows, :bc)
    qry.execute
  end

  def jsonify_notebook(notebook)
    {'uri' => "'#{notebook.uri}'",
      'public' => true,
      'author' => "'#{notebook.owner.name}'",
      'note' => "'#{notebook.notes}'",
      'title' => "'#{notebook.name}'",
      'subscribers' => "'#{notebook.followers.count}'",
      'bookmarks' => jsonify_bookmars(notebook)}
  end

  def jsonify_bookmars(notebook)
    res = []
    notebook.elements.each do |bookmark|
      res << {'uri' => "'#{bookmark.uri}'",
        'title' => "'#{bookmark.title}'",
        'qstring' => "'#{bookmark.qstring}'",
        'resourceType' => "'#{bookmark.resource_type}'",
        'note' => "'#{bookmark.notes}'",
        'date' => "'#{bookmark.date}" }
    end
    res
  end


  def get_bookmark_collections
    qry = ActiveRDF::Query.new(BookmarkCollection).select(:bc).distinct
    qry.where(:bc, N::TALIA.owner, @talia_user)
    @collections = qry.execute
  end

  def basic_auth
    #    user_email = @user.email_address
    authenticate_or_request_with_http_basic("Bookmarks") do |user, pass|
      @user = User.authenticate(user, pass) #if(@user.name == user)
    end
  end

end
