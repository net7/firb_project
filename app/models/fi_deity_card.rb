# This is represents a deity (divinta'), which is part of
# a cart in the FIRB FI parade
class FiDeityCard < IllustrationCard

  include FiCardsCommonFields
  extend FiCardsCommonFields::DefinedProperties

  common_properties
  autofill_uri :force => true

  singular_property :cart, N::TALIA.cart, :type => TaliaCore::ActiveSource

  def iconclasses(sort=true)
    super(sort, false)
  end

  def boxview_data
    { :controller => 'boxview/fi_deity_cards', 
      :title => self.name,
      :description => "",
      :res_id => "fi_deity_card_#{self.id}", 
      :box_type => 'image',
      :thumb => nil
    }
  end
end
