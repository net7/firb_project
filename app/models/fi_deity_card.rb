# This is represents a deity (divinta'), which is part of
# a cart in the FIRB FI parade
class FiDeityCard < IllustrationCard

  include FiCardsCommonFields
  extend FiCardsCommonFields::DefinedProperties
  include Mixin::HasParts

  common_properties
  autofill_uri :force => true

  singular_property :cart, N::TALIA.cart, :type => TaliaCore::ActiveSource

  def iconclasses(sort=true)
    super(sort, false)
  end

  # This is needed to use #sort 
  def <=>(deity)
    self.name < deity.name ? -1 : 1
  end

  def boxview_data
    title = "Carta #{self.anastatica.page_position} - #{self.name} - (#{self.cart.name})"
    { :controller => 'boxview/fi_deity_cards', 
      :title => title,
      :description => "",
      :res_id => "fi_deity_card_#{self.id}", 
      :box_type => 'image',
      :thumb => nil
    }
  end

  def parts_query
    nil
  end

  def additional_parts
    self.image_components
  end
end
