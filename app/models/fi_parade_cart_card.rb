# Represents a Cart (Carro) in the Parade of FIRB FI
class FiParadeCartCard < IllustrationCard
  
  include FiCardsCommonFields
  extend FiCardsCommonFields::DefinedProperties
  
  common_properties
  autofill_uri :force => true

  # @collection is a TaliaCore::Collection
  # returns the ordered list of element to be shown in the menu list
  def self.menu_items_for(collection)
    result = []
    cards = self.find(:all)
    cards.each do |c|
      my_index = collection.index(c)
      result[my_index] = c unless my_index.nil? #or !c.is_public?
    end
    result
  end

  def boxview_data
    { :controller => 'boxview/fi_parade_cart_cards', 
      :title => self.deity,
      :description => "",
      :res_id => "fi_parade_cart_card_#{self.id}", 
      :box_type => nil,
      :thumb => nil
    }
  end

  def deity
    @deity ||= FiDeityCard.find :first, :find_through => [N::TALIA.cart, self.uri]
  end
end
