# Pi illustration Card: scheda illustrazione (Firb Pi)
class PiIllustrationCard < IllustrationCard

  include StandardPermissions
  extend Mixin::Showable
  showable_in Anastatica
  include Mixin::Publish
  extend Mixin::Publish::PublishProperties
  setup_publish_properties
  
  autofill_uri :force => true
  
  # Short description: brief desc. of the depiction, say "Male person
  # drawing"
  singular_property :short_description, N::TALIA.short_description
  declare_attr_type :short_description, :text
   
  fields do
    uri :string
  end

  def children
    @children ||= PiIllustratedMdCard.find :all, :find_through => [N::TALIA.parent_card, self.uri]
  end

  def children_components_by_type
    return @children_components_by_type unless @children_components_by_type.nil?
    @children_components_by_type = {}
    self.children.each do |child|
      child.image_components.each do |component|
        (@children_components_by_type[component.zone_type.to_sym] ||= []) << component
      end
    end

    @children_components_by_type.each_key do |type|
      @children_components_by_type[type].sort! do |component1, component2|
        component1.name.to_s <=> component2.name.to_s
      end
    end
    @children_components_by_type
  end

  def iconclasses(sort=true, all=true)
    iconclasses = self.iconclass_terms.map {|iconclass| iconclass}

    self.children.each do |child|
      child.iconclass_terms.each do |iconclass|
        iconclasses << iconclass
      end
    end if all

    iconclasses.sort! do |iconclass1, iconclass2|
      iconclass1.label <=> iconclass2.label
    end if sort

    iconclasses
  end

  def boxview_data
    desc = self.short_description.nil? ? "" : "#{self.short_description.slice(0, 80)}.."
    { :controller => 'boxview/illustrazioni_madri', 
      :title => "Carta #{self.anastatica.page_position}", 
      :description => desc,
      :res_id => "pi_illustration_#{self.id}", 
      :box_type => 'image',
      :thumb => nil
    }
  end
  
end
