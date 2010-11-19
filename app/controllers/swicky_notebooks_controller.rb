#  =Swicky Notebooks API
# 
#  == Get the list of notebooks for a user
#  * '''URI:''' http://host/<user_name>/swicky_notebooks/
#  * '''HTTP:''' GET
#  * '''ACTION:''' index
#  * '''Formats:''' XML (<notebooks><notebook></notebook>...</notebooks>) and HTML
#
#  == Show a notebook
#  * '''URI:''' http://host/<user_name>/swicky_notebooks/<notebook_name>
#  * '''HTTP:''' GET
#  * '''ACTION:''' show
#  * '''Formats:''' XML, RDF(/XML) and HTML
#
#  == Upload a notebook
#  * '''URI:''' http://host/<user_name>/swicky_notebooks/<notebook_name>
#  * '''HTTP:''' POST
#  * '''ACTION:''' create
#  * '''Params:''' contentfile (file upload), containing the RDF/XML of the notebook
#
#  == Update a notebook
#  * '''URI:''' http://host/<user_name>/swicky_notebooks/<notebook_name>
#  * '''HTTP:''' PUT 
#  * '''ACTION:''' update
#  * '''Params:''' contentfile (file upload), containing the RDF/XML of the notebook
#
#  == Delete a notebook
#  * '''URI:''' http://host/<user_name>/swicky_notebooks/<notebook_name>
#  * '''HTTP:''' DELETE
#  * '''ACTION:''' destroy
# 
#  == Annotations for URI
#  * '''URI:''' http://host/swicky_notebooks/context/annotated_fragments/<encoded_uri>
#  * '''HTTP:''' GET
#  * '''ACTION:''' annotated_fragments
#  * '''Formats:''' Json
#  * '''Returns:''' List of XPath elements that refer to annotations on the given URL
#
#  == Get annotation triples
#  * '''URI:''' http://host/swicky_notebooks/context/annotations/
#  * '''HTTP:''' GET
#  * '''ACTION:''' create
#  * ''Formats:''' Json, HTML, XML/XML-RDF
#  * '''Params:''' "uri" or "xpointer", depending on the element for which to get
#     the annotations
#  * '''Returns:''': A Json/XML/Description of all triples that have to do with the
#     note which refers to the given parameter
#
#  == Authentication
# 
#  In general, all calls except the "GET" things require HTTP BASIC authentication with
#  the user's email address and password
class SwickyNotebooksController < ApplicationController
  
  before_filter :get_user, :except => [:annotated_fragments, :annotations, :related_topic]
  before_filter :basic_auth, :except => [:annotated_fragments, :annotations, :related_topic]
  before_filter :get_notebook, :except => [:index, :create, :annotated_fragments, :annotations, :related_topic]
  skip_before_filter :verify_authenticity_token

  rescue_from NativeException, :with => :rescue_native_error
  rescue_from(URI::InvalidURIError) { render_api_result(:illegal_parameter, "Illegal URI?") }
  
  # GET 
  def index
    @notebooks = Swicky::Notebook.find_all
  end

  # GET 
  def show
    raise(ActiveRecord::RecordNotFound, "Notebook doesn't exist #{@notebook.url}") unless(@notebook.exist?)
    respond_to do |format|
      format.xml { render :text => @notebook.xml_data }
      format.rdf { render :text => @notebook.xml_data }
      format.html { render }
    end
  end

  # POST
  def create
    @notebook = Swicky::Notebook.new(@user.name, params[:notebook_name])
    @notebook.delete
    @notebook.load(params[:contentfile].path)
    respond_to do |format|
      format.xml { render :text => @notebook.xml_data }
      format.rdf { render :text => @notebook.xml_data }
      format.html { render }
    end
  end
  
  # PUT
  def update
    @notebook.delete
    @notebook.load(params[:contentfile].path)
    render_api_result(:success, "Notebook updated")
  end
  
  # DELETE
  def destroy
    raise(ActiveRecord::RecordNotFound, "Notebook doesn't exist #{@notebook.url}") unless(@notebook.exist?)
    @notebook.delete
    render_api_result(:success, "Notebook deleted")
  end
  
  def annotated_fragments
    coordinates = Swicky::Notebook.coordinates_for(URI.escape(params[:uri]).to_s)
    render :text => coordinates.to_json
  end
  
  def annotations
    notes_triples = if(params[:uri])
      Swicky::Notebook.annotations_for_url(params[:uri])
    elsif(params[:xpointer])
      Swicky::Notebook.annotations_for_xpointer(params[:xpointer])
    else
      raise(ActiveRecord::RecordNotFound, "No parameter given for annotations")
    end
    respond_to do |format|
      format.xml { render :text => Swicky::ExhibitJson::ItemCollection.new(notes_triples, params[:xpointer] || params[:uri]).to_json }
      format.rdf { render :text => TaliaUtil::Xml::RdfBuilder.xml_string_for_triples(notes_triples) }
      format.html { render :text => TaliaUtil::Xml::RdfBuilder.xml_string_for_triples(notes_triples) }
      format.json { render :text => Swicky::ExhibitJson::ItemCollection.new(notes_triples, params[:xpointer] || params[:uri]).to_json }
    end
  end
  
  # TODO : fix related_topic action
  # Will render a rdf with all the useful sources connected to the given topic.
  # The topic is a valid URI, for example a source uri.
  # TODO: find a nice way to get data from each one of the possible models .. put something in file_attached.rb ? 
  # TODO: see ontologies_controller and its show view, a good example at how to use a builder and let him
  # do some work
  def related_topic
    record = TaliaCore::ActiveSource.find(params[:topic])
    
    # TODO: add some kind of list of allowed types, or use method responds_to(:whatever)
    if (record.respond_to?(:get_related_topic_descriptions))
      @triples = record.get_related_topic_descriptions
    end

    #respond_to do |format|
    #  format.rdf { render :text => text}
    #  format.html { render :text => "TODO: FIX HTML #{record.uri.to_s} #{record.type} <br><textarea rows='50' cols='100'>"+text+"</textarea>" }
    #end
  end
  
  private
  
  def rescue_native_error(exception)
    if(exception.cause.class.name =~ /\AJava::OrgOpenrdfQuery/)
      render_api_result(:illegal_parameter, "Query Error. Wrong URI?")
    else
      raise exception
    end
  end
  
  def render_api_result(result, message)
    result = Swicky::ApiResult.new(result, message)
    respond_to do |format|
      format.xml { render :text => result.to_xml, :status => result.http_status }
      format.rdf { render :text => result.to_xml, :status => result.http_status }
      format.html { render :text => result.to_html, :status => result.http_status }
      format.json { render :text => result.to_json, :status => result.http_status }
    end
  end
  
  def get_user
    @user = User.find_by_name(params[:user_name])
    raise(ActiveRecord::RecordNotFound, "No user #{params[:user_name]}") unless(@user)
  end
  
  def get_notebook
    @notebook = Swicky::Notebook.new(@user.name, params[:id])
  end
  
  def basic_auth
    return true if(request.get?)
    user_email = @user.email_address
    authenticate_or_request_with_http_basic("Swicky") do |user, pass|
      @auth_user = User.authenticate(user_email, pass) if(@user.name == user)
    end
  end
  
  
end
