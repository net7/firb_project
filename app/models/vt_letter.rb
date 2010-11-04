class VtLetter < TaliaCore::Collection

  hobo_model # Don't put anything above this

  include StandardPermissions
  extend RdfProperties

  autofill_uri :force => true

  declare_attr_type :name, :string
  declare_attr_type :title, :string
  
  rdf_property :introduction, N::TALIA.introduction, :type => :text
  rdf_property :letter_number, N::TALIA.letter_number, :type => :string
  
  def name
    title.blank? ? uri.local_name : title
  end

  def handwritten_cards
    ordered_objects.find_all { |el| el.is_a?(VtHandwrittenTextCard) }
  end

  def printed_cards
    ordered_objects.find { |el| el.is_a?(VtPrintedTextCard) }
  end

end