class Procession < TaliaCore::Collection

  hobo_model # Don't put anything above this
  validate :only_carts_and_characters

  include StandardPermissions
  extend RdfProperties

  autofill_uri :force => true

  declare_attr_type :name, :string
  declare_attr_type :title, :string

  def name
    title.blank? ? uri.local_name : title
  end

  def characters
    ordered_objects.find_all { |el| el.is_a?(FirbParadeCharacterCard) }
  end

  def cart
    ordered_objects.find { |el| el.is_a?(FirbParadeCartCard) }
  end

  def only_carts_and_characters
    cart_seen = false
    ordered_objects.each do |element|
      if(element.is_a?(FirbParadeCartCard))
        # We can allow at most one cart in the procession
        cart_seen ? errors.add_to_base(I18n.t('processions.errors.too_many_carts')) : (cart_seen = true)
      else
        # If we don't have a cart, it should be a character
        errors.add_to_base(I18n.t('processions.errors.illegal_type', element.uri)) unless(element.is_a?(FirbParadeCharacterCard))
      end
    end
  end

end