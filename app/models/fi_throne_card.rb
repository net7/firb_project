# Represents a throne (trono), which is part of a card in
# the FIRB FI parade
class FiThroneCard < IllustrationCard

  include FiCardsCommonFields
  extend FiCardsCommonFields::DefinedProperties
  include Mixin::HasParts

  common_properties
  autofill_uri :force => true

  singular_property :cart, N::TALIA.cart, :type => TaliaCore::ActiveSource

  def iconclasses(sort=true)
    super(sort, false)
  end

  def boxview_data
    { :controller => 'boxview/fi_throne_cards', 
      :title => self.name,
      :description => "",
      :res_id => "fi_throne_card_#{self.id}", 
      :box_type => 'image',
      :thumb => nil
    }
  end

  def parts_query
    nil
  end

  def additional_parts
    ic = self.image_components || []
    n = self.notes || []
    ic + n
  end
end
