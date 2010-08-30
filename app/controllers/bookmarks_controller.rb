require "base64"
class BookmarksController < ApplicationController
  hobo_controller

  before_filter :basic_auth, :except => :my_doni_login_box
  before_filter :get_talia_user, :except => :my_doni_login_box
  before_filter :get_bookmark_collections, :except => :my_doni_login_box

  # Returns the form for the frontend's new/modify dialog
  def get_bookmark_dialog

    load_notebooks_vars
    qstring = Base64.decode64(params[:qstring])

    # TODO: move this html to a view or another partial ..
    html = "<div class='dialog_accordion'>"

    # Insert the standard 'new' bookmark part
    bm = {:qstring => qstring, :title => params[:title], :resourceType => params[:resourceType], :resourceTypeString => params[:resourceTypeString]}
    html += render_to_string :partial => '/bookmarks/bookmark_new_dialog.html', :locals => { :bm => bm }

    # Use my notebooks to render the edit forms
    # TODO: need to filter @my_notebooks to get out only those having a bm which refers to params[:qstring]

    @my_jsonified = jsonify_and_filter_notebook_by_qstring(@my_notebooks, qstring)
    html += render_to_string :partial => '/bookmarks/bookmark_edit_dialog.html', :locals => { :my => @my_jsonified } unless @my_jsonified.empty?
    
    # TODO: remove this html as before
    html += "</div>"

    data = {:error => 0, :html => html}
    render_json(html, data, 0)
  end

  # Returns an entire box with all of its notebook's widgets
  def get_notebook_box
    @notebook = BookmarkCollection.find(Base64.decode64(params[:uri]))
    html = render_to_string :partial => '/bookmarks/notebook_widget.html', :object => @notebook
    data = {:error => 0, :box => @notebook.title, :html => html}
    render_json(html, data, 0)
  end

  # Returns a widget to be inserted at the top of a content box, with all the notebooks which
  # contains the given qstring in one of its bookmarks. The notebooks will contain only the 
  # bookmarks of the given qstring
  def get_my_doni_widget
    load_notebooks_vars
    qstring = Base64.decode64(params[:qstring])

    @my_jsonified = jsonify_and_filter_notebook_by_qstring(@my_notebooks, qstring)
    @sub_jsonified = jsonify_and_filter_notebook_by_qstring(@subscribed_notebooks, qstring)

    html = render_to_string :partial => '/bookmarks/my_doni_widget.html', :locals => { :my => @my_jsonified, :subscribed => @sub_jsonified}
    data = {:error => 0, :html => html}
    render_json(html, data, 0)
  end


    # new_bookmark/new_notebook/.. wrapper: will check the params[] array
    # creates the notebook if needed and create/modify the bookmark
    def save_bookmark

        nb_uri = params[:sel_nb]
        # Are we creating a new notebook?
        if (params[:create_new_notebook] == 'true') then
            p = {:title => params[:newnb_title], :notes => params[:newnb_note], :public => params[:newnb_public]}
            notebook = BookmarkCollection.create_bookmark_collection(p)
            notebook.set_owner(@talia_user)
            notebook.save!
            nb_uri = notebook.uri
        end

        # No URI: we are creating a new bookmark
        if (params[:uri].nil?) then
            p = {:qstring => params[:qstring], :title => params[:title], :notes => params[:notes], 
                :resource_type => params[:resourceType]}
            bookmark = TaliaBookmark.create_bookmark(p)
            notebook = BookmarkCollection.find(nb_uri)
            notebook.add_bookmark(bookmark)
            bookmark.save!

        # URI: we are editing an existing bookmark
        else
            bookmark = TaliaBookmark.find(params[:uri])
            bookmark.notes = params[:notes]
            bookmark.date = Time.now
            bookmark.save!

            # Let's see if the user has changed this bookmark's notebook
            if (params[:oldnb_uri] != nb_uri)
                old_nb = BookmarkCollection.find(params[:oldnb_uri])
                old_nb.detach_bookmark(bookmark.uri)
                notebook = BookmarkCollection.find(nb_uri)
                notebook.add_bookmark(bookmark)
                notebook.save!
            end
        end

        html = "Created with qstring " + Base64.decode64(params[:qstring])
        data = {:error => 0, :html => html}
        render_json(html, data, 0)
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
    render_json(html, data, 0)
  end

  # creates a new notebook
  def new_notebook
    notebook = BookmarkCollection.create_bookmark_collection(params)
    notebook.set_owner(@talia_user)
    notebook.save!
    html = notebook.uri
    data = {}
    render_json(html, data, 0)
  end

  # Deletes a notebook and all its bookmarks
  # it uss the notebook URI passed in the :notebook param to identify the notebook
  # to be deleted
  def delete_notebook
    notebook_uri = params.delete(:notebook)
    notebook = BookmarkCollection.find(notebook_uri)
    notebook.elements.each do |bookmark|
      bookmark = bookmark.becomes(TaliaBookmark)
      bookmark.destroy
    end
    notebook.destroy
    html = 'deleted'
    data = {}
    render_json(html, data, 0)
  end


  def follow_notebook
    notebook = BookmarkCollection.find(params[:uri])
    raise if notebook.nil? or !notebook.is_a? BookmarkCollection
    notebook.add_follower(@talia_user)
    html = notebook.uri
    data = {}
    render_json(html, data, 0)
  end


  def render_html_index
    html = render_to_string "bookmark/index"
    data = {'box' => 'Bookmarks'}
    render_json(html, data, 0)
  end

  # First request for a login box
  def my_doni_login_box
      html = render_to_string :partial => '/bookmarks/my_doni_login_box.html'
      data = {:error => 0, :html => html, :box => "myDoni :)"}
      render_json(html, data, 0)
  end

  # Return a box with the login panel for a logged in user, along with all of his
  # bookmarks, notebooks and preferences
  def index
    load_notebooks_vars
    respond_to do |format|
      format.json {render_json_index}
      format.html {render_html_index}
    end
  end

  def render_json_index

    load_notebooks_vars
    html = render_to_string :partial => '/bookmarks/my_doni_index.html', :locals => { :my => @my_notebooks, :subscribed => @subscribed_notebooks }

    notebooks = []
    @my_notebooks.each{|n| notebooks << jsonify_notebook(n) }
    @subscribed_notebooks.each{|n| notebooks << jsonify_notebook(n) }

    # prefs: contains the preference object got from the frontend on a
    #        preference save action
    # notebooks: contains all the notebooks this user is subscribed to/owner of
    # login_panel_html: html code for the my doni box
    
    json = { 'error' => 0, 
            'data' => {
                'prefs' => {
                    'name' => @user.name,
                    'resizemeImagesMaxWidth' => '600',
                    'animations' => 1,
                    'useCookie' => true
                    },
                'notebooks' => notebooks,
                'my_doni_html' => html
            }
    }
    
    render :json => json
  end

  # Deletes a bookmark in a notebook
  # needs both notebook and bookmark URIs, passed in :notebook and :bookmark params
  def delete_bookmark
    notebook = BookmarkController.find(params[:notebook])
    bookmark = TaliaBookmark.find(params[:bookmark])

    notebook.detach_bookmark(params[:bookmark])
    bookmark.destroy

    html = 'deleted'
    data = {}
    render_json(html, data, 0)
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

  def autocomplete_notebook_title
      qry = ActiveRDF::Query.new(BookmarkCollection).select(:bc).distinct
      qry.where(:bc, N::TALIA.owner, :zz)

      # TODO: do this search in the proper way (R)
      # The owner is checked just by the name .. 
      notebooks = qry.execute
      notebooks = notebooks.select { |n| "#{n.title}".include?(params[:term]) }
      notebooks = notebooks.select { |n| n.owner.name != @talia_user.name }
      notebooks.collect! { |n| {:id => "#{n.uri}", :label => "#{n.title}", :value => "#{n.owner.name}: #{n.title}"  }}
      render :json => notebooks
  end


  private

  # First jsonifies an array of notebooks, then filters out those nb which dont contain
  # at least a bookmark referring qstring. It filters the bookmarks as well
  def jsonify_and_filter_notebook_by_qstring (notebooks, qstring)
      jsonified = []
      notebooks.each   { |n| jsonified << jsonify_notebook(n) }
      jsonified.each   { |n| n['bookmarks'] = n['bookmarks'].select { |b| b['qstring'] == qstring } }
      jsonified.select { |n| n['bookmarks'] != [] }
  end


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
    qry.where(:bc, N::TALIA.followedBy, @talia_user)
    qry.execute
  end

  def jsonify_notebook(notebook)
    {'uri' => "#{notebook.uri}",
      'public' => true,
      'author' => "#{notebook.owner.name}",
      'note' => "#{notebook.notes}",
      'title' => "#{notebook.title}",
      'subscribers' => "#{notebook.followers.count}",
      'bookmarks' => jsonify_bookmarks(notebook)}
  end

  def jsonify_bookmarks(notebook)
    res = []
    notebook.elements.each do |bookmark|
      bookmark = bookmark.becomes(TaliaBookmark)
      res << {'uri' => "#{bookmark.uri}",
        'title' => "#{bookmark.title}",
        'qstring' => "#{bookmark.qstring}",
        'resourceType' => "#{bookmark.resource_type}",
        'note' => "#{bookmark.notes}",
        'date' => "#{bookmark.date}" }
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
