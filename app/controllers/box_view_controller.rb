require "base64"
class BoxViewController < ApplicationController
  include TaliaCore

  layout nil

  NO_ERRORS = 0
  ERROR_DB_NOT_RESPONDING = 1
  ERROR_INTERNAL = 2
  ERROR_UNKNOWN_METHOD = 10
  ERROR_UNKNOWN_PARAMETER = 11
  ERROR_MISSING_PARAMETER = 12
  ERROR_INVALID_PARAMETER = 13
  ERROR_UNKNOWN_LANGUAGE = 20
  ERROR_UNKNOWN_EXCEPTION = 99

  # GET /boxView/
  def index
    @title = 'boxed view!' #TaliaCore::CONFIG['site_name']
    @small_title = TaliaCore::CONFIG['site_name']
  end

  # GET /boxView/dispatch?method=XX
  #
  # the frontend sends back ajax requests, which are meant to be dispatched
  # based on get parameters.
  def dispatch
    error_code = NO_ERRORS

    case params[:method]
    when 'getIntro'
      html = render_to_string :intro
      data = {'box' => "welcome"}
    when 'getMenu'
      render_menu and return
    when 'getSource'
      render_source and return
    when 'filter'
      render_filter and return
    else
      error_code = ERROR_UNKNOWN_METHOD
      html = "Unable to fulfil the request! (Unknown method: #{params[:method]}"
      data = {'box' => 'error'}
    end

    render_json(error_code, html, data)
  end

  # Display the left side menu
  def render_menu
    @elements = N::SourceClass.subclass_hierarchy { |sc| sc.used? && (sc.to_uri.namespace != :owl) && (sc.to_uri.namespace != :rdfs) && (sc.to_uri.namespace != :rdf) && (sc.to_uri.namespace != :talia)} 

    html = render_to_string :menu
    data = ''
    render_json(0, html, data)
  end

  # Display a list of items, of the given RDF type
  def render_filter
    filter = params[:type]

    qry = ActiveRDF::Query.new.select(:t)
    qry.where(:t, N::RDF.type, N::URI.make_uri(filter, '+'))
    @elements = qry.execute

    html = render_to_string :item_list
    data = {'box' => filter.split('+').last.pluralize}
    render_json(0, html, data)
  end

  # A source has been requested.  
  # We deal with it here, and display an appropriate box
  def render_source


    @id = rand Time.now.to_i

    source_uri = Base64.decode64(params[:resource])
    @source = TaliaCore::ActiveSource.find(source_uri)
    
    if @source.is_a? BgIllustrationCard
      # Imprese - FIRB_BG
      @image = @source.anastatica.image_zone.get_image_parent 
      html = render_to_string :firb_bg
      data = {'box' => 'Illustrazione'}
      
    elsif @source.is_a? PiIllustrationCard
      # Memoria - FIRB_PI
      @image = @source.image_zone.get_image_parent
        
      @anastatica = @source.anastatica
      qry = ActiveRDF::Query.new(PiTextCard).select(:ptc).distinct
      qry.where(:ptc, N::DCT.isPartOf, @anastatica.uri)
      pi_text_cards = qry.execute
        
      unless pi_text_cards.empty?
        pi_text_cards.each do |ptc|
          @non_illustrated_md = ptc.non_illustrated_memory_depictions
        end
      end
      html = render_to_string :firb_pi
      data = {'box' => 'Illustrazione'}
      
    elsif @source.is_a? FiCharacterCard
      # Mascherata - FIRB_FI
      @image = @source.anastatica.image_zone.get_image_parent
      html = render_to_string :firb_fi
      data = {'box' => 'Personaggio'}


    elsif @source.is_a? VtLetter
      # Aretino - FIRB_VT
      case params[:mode]

      
      when 'DiplomaticTranscription'
        # we need to show the PDF file related to the whole letter
      else        

        # we show the letter itself
        @handwritten_images = []
        @printed_images = []
        unless (hwc = @source.handwritten_cards).empty? 
          hwc.uniq.each do |h|
            @handwritten_images << h.anastatica.image_zone.get_image_parent
          end

          @first_handwritten_card = hwc.first
        end
        
        unless (pc = @source.printed_cards).empty? 
          pc.uniq.each do |p|
            @printed_images << p.anastatica.image_zone.get_image_parent
          end
          @first_printed_card = pc.first
        end

        
        
        html = render_to_string :firb_vt_letter
        data = {'box' => 'Lettera'}
      end
   
    elsif @source.is_a? VtHandwrittenTextCard
    
      letter = @source.letter
      unless (hwc = letter.handwritten_cards.uniq).nil?
        if (curr_index = hwc.index @source) > 0
          @prev_page = hwc[curr_index - 1]
        end
        if (curr_index < (hwc.count - 1))
          @next_page = hwc[curr_index + 1]
        end

        @transcription_html = ''
      
        file = @source.data_records.find_by_type_and_location('TaliaCore::DataTypes::XmlData','html1.html')
        @transcription_html = file.all_text unless file.nil?
      

        @image = @source.anastatica.image_zone.get_image_parent


        html = render_to_string :firb_vt_transcription
        data = {'box' => 'Trascrizione Critica Manoscritto'}
      
      
      end

    elsif @source.is_a? VtPrintedTextCard

      letter = @source.letter
      unless (pc = letter.printed_cards.uniq).nil?
        if (curr_index = pc.index @source) > 0
          @prev_page = pc[curr_index - 1]
        end
        if (curr_index < (pc.count - 1))
          @next_page = pc[curr_index + 1]
        end

        @transcription_html = ''
      
        file = @source.data_records.find_by_type_and_location('TaliaCore::DataTypes::XmlData','html1.html')
        @transcription_html = file.all_text unless file.nil?

        @image = @source.anastatica.image_zone.get_image_parent

        html = render_to_string :firb_vt_transcription
        data = {'box' => 'Trascrizione Critica Stampa'}
      
      
      end

    end
             
    # types = ActiveRDF::Query.new(N::URI).select(:type).distinct.where(@source, N::RDF.type, :type).execute
    # if  N::DEMO.Person.in? types
    #   html = render_to_string :person
    # elsif N::DEMO.City.in? types
    #   html = render_to_string :city
    # else
    #   html = render_to_string :source
    # end
    #    data = {'box' => TaliaCore::ActiveSource.find(source_uri).uri.to_uri.local_name.to_s.gsub('_', ' ')}

    render_json(0, html, data)
  end


  private

  # Serves the data in the format required by the javascript driving the User Interface
  def render_json(error, html, data)
    # javascript script "error.js" will complain if we pass a real json object as we could
    # by using the following code (aka the correct way to pass json)
    render :json => {'error' => error,
      'html' => html,
      'data' => data
    }

    # hence we render a string

    #    json_data = {'error' => error,
    #      'html' => html,
    #      'data' => data
    #    }
    #
    #    render :inline => json_data.to_json('html')

  end


end
