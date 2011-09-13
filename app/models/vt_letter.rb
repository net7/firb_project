class VtLetter < TaliaCore::Collection

  hobo_model # Don't put anything above this

  include StandardPermissions
  include FileAttached
  extend RdfProperties

  autofill_uri :force => true

  declare_attr_type :name, :string
  declare_attr_type :title, :string
  
  rdf_property :introduction, N::TALIA.introduction, :type => :text
  rdf_property :letter_number, N::TALIA.letter_number, :type => :string
  rdf_property :date, N::DCNS.date
  rdf_property :date_string, N::TALIA.date_string, :type => :string
  rdf_property :printed_collocation, N::TALIA.printed_collocation, :type => :string
  rdf_property :handwritten_collocation, N::TALIA.handwritten_collocation, :type => :string

  def self.edition_title_for(edition)
    begin
      result = edition.name.nil? ? "" : "(#{edition.name})"
      result << " #{edition.bibliography_item.author}: #{edition.bibliography_item.title} "
      result << (edition.pages.nil? ? "" : " ("+edition.pages+")")
    rescue
      ""
    end
  end

  ##
  # This model is a special case: it is actually called to show either its handwritten or printed cards.
  #
  # See use in the index (views/boxview/indici/vt.html.erb).

  def boxview_data
    desc = self.date_string
    { :controller => 'boxview/vt_letters_vt_handwritten_text_cards',
      :title => self.name,
      :description => desc,
      :res_id => "vt_letter_#{self.id}", 
      :box_type => 'image',
      :thumb => nil,
      :url => "boxview/vt_letters_vt_handwritten_text_cards/#{self.id}"
    }
  end

  # used for #sort
  def <=>(letter)
    self.date < letter.date  ? -1 : 1
  end

  def name
    title.blank? ? uri.local_name : title
  end

  def handwritten_cards
    ordered_objects.find_all { |el| el.is_a?(VtHandwrittenTextCard) }
  end

  def printed_cards
    ordered_objects.find_all { |el| el.is_a?(VtPrintedTextCard) }
  end

  def handwritten_reference_edition
    begin
      @handwritten_reference_edition ||= handwritten_cards.first.bibliography_items.first
    rescue
      nil
    end
  end

  def printed_reference_edition
    begin
      @printed_reference_edition ||= printed_cards.first.bibliography_items.first
    rescue
      nil
    end
  end


  # returns list of date_string values 
  def self.menu_items_by_date
    VtLetter.find(:all).sort
  end


    # returns list of date_string values 
  def self.menu_items_by_recipient
    VtLetter.find(:all).sort
  end

end
