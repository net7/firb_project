class FiProcession < TaliaCore::Collection

  hobo_model # Don't put anything above this
  validate :only_carts_and_characters
  before_validation :validate_parade
  after_save :save_parade

  include StandardPermissions
  extend RdfProperties

  autofill_uri :force => true

  declare_attr_type :name, :string
  declare_attr_type :title, :string
  manual_property :parade

  # Manual property procession getter and setter
  def parade
    @parade ||= fetch_parade
  end
  
  def parades
    return [] if(new_record?)
    [parade]
  end

  def unattached_parades
    p = FiParade.all
    return p if (new_record?)
    attached = parade
    p.reject { |att| attached.to_uri == att.to_uri }
  end
  
  def parade=(value)
    @parade = (value.is_a?(FiParade) ? value : FiParade.find(value))
    @parade_new = true
    @parade << self
  end

  # If there's errors validating the parade, add these errors to this
  # object's errors and return false
  def validate_parade
    if(!parade_valid?)
      @parade.errors.each_full { |msg| errors.add('parade', msg) }
    end
    parade_valid?
  end
  
  def save_parade
    is_new = @parade_new
    @parade_new = false
    is_new ? @parade.save : parade_valid?
  end
  
  def fetch_parade
    FiParade.find(:first, :find_through => [N::DCT.hasPart, self.uri])
  end

  def parade_valid?
    @parade ? @parade.valid? : true
  end

  def name
    title.blank? ? uri.local_name : title
  end

  def characters
    ordered_objects.find_all { |el| el.is_a?(FiCharacterCard) }
  end

  def cart
    ordered_objects.find { |el| el.is_a?(FiParadeCartCard) }
  end

  def only_carts_and_characters
    cart_seen = false
    ordered_objects.each do |element|
      if(element.is_a?(FiParadeCartCard))
        # We can allow at most one cart in the procession
        cart_seen ? errors.add_to_base(I18n.t('procession.errors.too_many_carts')) : (cart_seen = true)
      else
        # If we don't have a cart, it should be a character
        errors.add_to_base(I18n.t('procession.errors.illegal_type', :type => element.class.name )) unless(element.is_a?(FiCharacterCard))
      end
    end
  end

end