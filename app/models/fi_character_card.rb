# Represents a character in the FIRB FI parade. A character may or may not be following
# a cart. Cart+following characters build a procession. A book is an ordered list of
# processions.
class FiCharacterCard < IllustrationCard

  autofill_uri

  include FiCardsCommonFields
  extend FiCardsCommonFields::DefinedProperties
  include Mixin::HasParts

  include Mixin::Searchable
  include Mixin::Facetable::Fi

  common_properties

  rdf_property :qualities_age, N::TALIA.qualities_age, :type => :string
  rdf_property :qualities_gender, N::TALIA.qualities_gender, :type => :string
  rdf_property :qualities_profession, N::TALIA.qualities_profession, :type => :string
  rdf_property :qualities_ethnic_group, N::TALIA.qualities_ethnic_group, :type => :string

  # Bibliografia moderna
  multi_property :modern_bibliography_items, N::TALIA.hasModernBibliograhy, :type => TaliaCore::ActiveSource

  def cart
    procession.cart
  end

  # TODO: intelligent conversion to string?
  def procession_position
    procession.index(self).to_i + 1
  end

  def procession_characters
    procession.select {|el| el.is_a? FiCharacterCard}
  end

  # This is needed to use #sort 
  def <=>(character)
    self.name < character.name ? -1 : 1
  end


  def boxview_data
    title = "Carta #{self.anastatica.page_position} - #{self.name}"
    title += " - (#{self.cart.name})" if self.cart.present?
    
    { :controller => 'boxview/fi_character_cards', 
      :title => title,
      :description => "",
      :res_id => "fi_character_card_#{self.id}", 
      :box_type => 'image',
      :thumb => nil
    }
  end

  def iconclasses(sort=true)
    super(sort, false)
  end

  # FIXME (and remove me!)
  # def fetch_procession
  #   if super.is_a? FiProcession
  #     super
  #   else
  #     FiProcession.find(:first, :find_through => [N::DCT.hasPart, self])
  #   end
  # end

  def parts_query
    nil
  end

  def additional_parts
    ic = self.image_components.to_a || []
    n = self.notes || []
    ic + n
  end
end
