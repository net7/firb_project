module Admin::BaseCardsHelper

  # Will produce an array for an html select for the given card
  # type
  def base_cards_select(type)
    foo = type.constantize.find(:all)
    foo.collect! {|c| ["#{c.name}", c.uri.to_s]}
    foo.sort
  end

  def cart_child_cards(type, cart)
    foo = type.constantize.find(:all)
    foo.select { |c| !c.cart.nil? && c.cart.uri == cart.uri }
  end

  def vehicle_child_cards(vehicle)
    foo = FiEpisodeCard.all
    foo.select { |c| !c.vehicle.nil? && c.vehicle.uri == vehicle.uri }
  end

end
