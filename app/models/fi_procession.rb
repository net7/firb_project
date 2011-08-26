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

  # A procession belongs to one and only one parade
  manual_property :parade

  # Manual property procession getter and setter
  def parade
    @parade ||= fetch_parade
  end
  
  def parade=(value)
    if (!value.empty?)
      @parade = (value.is_a?(FiParade) ? value : FiParade.find(value))
      @parade_new = true
      
      old_parade = fetch_parade
      if !old_parade.nil? && old_parade.to_uri != @parade.to_uri
        # FIXME: ? the following line will not work for some reasons
        # the thing is that you can use delete only passing to it an element retrieved from the collection itself...
#       old_parade.delete self
        old_parade.each do |el|
          if el.uri == self.uri
            old_parade.delete el
            break
          end
        end

        old_parade.save

        @parade << self
      elsif old_parade.nil?
        @parade << self
      end
    end
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
    ActiveRDF::Query.new(FiParade).select(:parade).where(:parade, N::DCT.hasPart, self).execute.first
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
        cart_seen ? errors.add_to_base(I18n.t('fi_processions.errors.too_many_carts')) : (cart_seen = true)
      else
        # If we don't have a cart, it should be a character
        errors.add_to_base(I18n.t('fi_processions.errors.illegal_type', :type => element.class.name )) unless(element.is_a?(FiCharacterCard))
      end
    end
  end

  def boxview_data
    { :controller => 'boxview/fi_processions', 
      :title => "Corteo #{self.name}",
#      :description => self.description,
      :res_id => "fi_procession_#{self.id}", 
      :box_type => 'image',
      :thumb => nil
    }
  end

  # @collection is a FiParade
  # returns the ordered list of element to be shown in the menu list
  def self.menu_items_for(collection)
    result = []
    cards = self.find(:all)
    cards.each do |c|
      my_index = collection.index(c)
      result[my_index] = c unless my_index.nil? #or !c.is_public?
    end
    result.compact
  end



end
