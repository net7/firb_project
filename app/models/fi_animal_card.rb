# This represent the animal(s) which are part of 
# a cart in the FIRB FI parade
class FiAnimalCard < IllustrationCard

  include FiCardsCommonFields
  extend FiCardsCommonFields::DefinedProperties
  include Mixin::HasParts
  include Mixin::Searchable

  common_properties
  autofill_uri :force => true

  singular_property :cart, N::TALIA.cart, :type => TaliaCore::ActiveSource
  
  def iconclasses(sort=true)
    super(sort, false)
  end

  def boxview_data
    title = "Carta #{self.anastatica.page_position} - #{self.name}"
    { :controller => 'boxview/fi_animal_cards', 
      :title => title,
      :description => "",
      :res_id => "fi_animal_card_#{self.id}", 
      :box_type => 'image',
      :thumb => nil
    }
  end

  def parts_query
    nil
  end

  def additional_parts
    ic = self.image_components.to_a || []
    n = self.notes || []
    ic + n
  end
end
