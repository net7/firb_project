# Pi illustration Card: scheda illustrazione (Firb Pi)
class PiIllustrationCard < IllustrationCard

  include StandardPermissions
  extend Mixin::ShownInAnastatica
  
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
end
