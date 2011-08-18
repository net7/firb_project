# Represents a Cart (Carro) in the Parade of FIRB FI
class FiParadeCartCard < IllustrationCard
  
  include FiCardsCommonFields
  extend FiCardsCommonFields::DefinedProperties
  include Mixin::HasParts
  
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
      :description => self.description,
      :res_id => "fi_parade_cart_card_#{self.id}", 
      :box_type => nil,
      :thumb => nil
    }
  end

  def deity
    @deity  ||= FiDeityCard.find :first, :find_through => [N::TALIA.cart, self.uri]
  end

  def throne
    @throne ||= FiThroneCard.find :first, :find_through => [N::TALIA.cart, self.uri]
  end

  def vehicle
    @vehicle ||= FiVehicleCard.find :first, :find_through => [N::TALIA.cart, self.uri]
  end

  def animal
    @animal ||= FiAnimalCard.find :first, :find_through => [N::TALIA.cart, self.uri]
  end

  # FIXME (and remove me!)
  def fetch_procession
    if super.is_a? Array
      super
    else
      ActiveRDF::Query.new(FiProcession).select(:procession).where(:procession, N::DCT.hasPart, self).execute
    end
  end

  # TODO: intelligent conversion to string?
  def procession_position
    procession.index(self).to_i + 1
  end

  def procession_characters
    procession.select {|el| el.is_a? FiCharacterCard}
  end

  def children
    [deity, throne, vehicle, animal].compact
  end

  ##
  # Rewrite of HasParts#can_show? to make all parts "showable".
  #
  def can_show?(klass)
    true
  end
end
