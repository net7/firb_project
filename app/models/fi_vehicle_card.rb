# Represents the vehicle that is part of a whole cart in the
# FIRB FI parade. 
class FiVehicleCard < IllustrationCard

  include FiCardsCommonFields
  extend FiCardsCommonFields::DefinedProperties
  include Mixin::HasParts

  common_properties
  autofill_uri :force => true

  singular_property :cart, N::TALIA.cart, :type => TaliaCore::ActiveSource

  def episodes
    FiEpisodeCard.find(:all, :find_through => [N::TALIA.vehicle, self])
  end
  # Used by IllustrationCard#iconclasses
  alias_method :children, :episodes

  def boxview_data
    { :controller => 'boxview/fi_vehicle_cards', 
      :title => self.name,
      :description => "",
      :res_id => "fi_vehicle_card_#{self.id}", 
      :box_type => 'image',
      :thumb => nil
    }
  end

  def parts_query
    nil
  end

  def additional_parts
    e = self.episodes.map do |e|
      e.image_components.to_a
    end.flatten

    n = self.notes || []
    e + n
  end
end
