# Represents a character in the FIRB FI parade. A character may or may not be following
# a cart. Cart+following characters build a procession. A book is an ordered list of
# processions.
class FiCharacterCard < IllustrationCard
  
  autofill_uri
  
  include FiCardsCommonFields
  extend FiCardsCommonFields::DefinedProperties
  
  common_properties
  
  rdf_property :qualities_age, N::TALIA.qualities_age, :type => :string
  rdf_property :qualities_gender, N::TALIA.qualities_gender, :type => :string
  rdf_property :qualities_profession, N::TALIA.qualities_profession, :type => :string
  rdf_property :qualities_ethnic_group, N::TALIA.qualities_ethnic_group, :type => :string
  
  def boxview_data
    { :controller => 'boxview/fi_character_cards', 
      :title => self.name,
      :description => "",
      :res_id => "fi_character_card_#{self.id}", 
      :box_type => 'image',
      :thumb => nil
    }
  end
end
