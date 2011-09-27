# An episode that is part of a vehicle in the FIRB FI parade
class FiEpisodeCard < IllustrationCard

  include FiCardsCommonFields
  extend FiCardsCommonFields::DefinedProperties

  common_properties
  autofill_uri :force => true

  singular_property :vehicle, N::TALIA.vehicle, :type => TaliaCore::ActiveSource

  def cart
    vehicle.cart
  end

  def iconclasses(sort=true)
    super(sort, false)
  end

  def boxview_data
    title = "Carta #{self.anastatica.page_position} - #{self.name}"
    { :controller => 'boxview/fi_episode_cards', 
      :title => title,
      :description => self.description,
      :res_id => "fi_episode_card_#{self.id}", 
      :box_type => 'image',
      :thumb => nil
    }
  end
end
