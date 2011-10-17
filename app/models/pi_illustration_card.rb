# Pi illustration Card: scheda illustrazione (Firb Pi)
class PiIllustrationCard < IllustrationCard

  include StandardPermissions
  extend Mixin::Showable
  showable_in Anastatica
  include Mixin::Publish
  extend Mixin::Publish::PublishProperties
  setup_publish_properties
  
  include Mixin::Searchable

  autofill_uri :force => true
  
  # Short description: brief desc. of the depiction, say "Male person
  # drawing"
  singular_property :short_description, N::TALIA.short_description
  declare_attr_type :short_description, :text
   
  fields do
    uri :string
  end

  def children
#    @children ||= PiIllustratedMdCard.find :all, :find_through => [N::TALIA.parent_card, self.uri]
    @children ||= self.child_cards
  end


  def children_components
    res = []
    self.children.each do |child|
      child.image_components.each do |component|
        res << component
      end
    end
    res.compact.uniq
  end

  def children_components_by_type
    return @children_components_by_type unless @children_components_by_type.nil?
    @children_components_by_type = {}
    self.children.each do |child|
      child.image_components.each do |component|
        (@children_components_by_type[component.zone_type.to_sym] ||= []) << component
      end
    end
    
    self.image_components.each do |component|
       (@children_components_by_type[component.zone_type.to_sym] ||= []) << component
    end

    @children_components_by_type.each_key do |type|
      @children_components_by_type[type].sort! do |component1, component2|
        component1.name.to_s <=> component2.name.to_s
      end
    end
    @children_components_by_type
  end

  def boxview_data
    desc = self.short_description.nil? ? "" : "#{self.short_description.slice(0, 80)}.."
    { :controller => 'boxview/illustrazioni_madri', 
      :title => "Illustrazione: #{self.anastatica.page_position}", 
      :description => desc,
      :res_id => "pi_illustration_#{self.id}", 
      :box_type => 'image',
      :thumb => nil
    }
  end

  def additional_parts
    ic = self.image_components.to_a || []
    ic
  end


  # @collection is a TaliaCore::Collection
  # returns the ordered list of element to be shown in the menu list
  def self.menu_items_for(collection)
    result = []
    cards = self.find(:all)
    cards.each do |c|
      unless c.nil?
        anastatica = c.anastatica
        my_index = collection.index(anastatica)
        result[my_index] = c unless my_index.nil? or !c.is_public?
      end
    end
    result.compact
  end

  # @collection is a TaliaCore::Collection
  # returns the ordered list of element to be shown in the menu list
  def self.filtered_menu_items_for(collection, filter)
    result = []
    cards = ImageComponent.items_by_type_and_related_resource_class(filter, PiIllustrationCard)
    cards.each do |c|
      unless c.nil?
        anastatica = c.anastatica
        my_index = collection.index(anastatica)
        result[my_index] = c unless my_index.nil? or !c.is_public?
      end
    end
    result.compact
  end
      

end


