class FirbParentIllustrationCard < FirbIllustrationCard
  
  include StandardPermissions
  
  # Short description: brief desc. of the depiction, say "Male person
  # drawing"
  singular_property :short_description, N::TALIA.short_description
  declare_attr_type :short_description, :text
  singular_property  :textual_source, N::TALIA.attachedText
   
  fields do
    uri :string
  end
  
  
  def child_cards
    ActiveRDF::Query.new(FirbIllustratedMemoryDepictionCard).select(:card).where(:card, N::TALIA.parent_card, self).execute
  end
  
  def component_zones
    ActiveRDF::Query.new(FirbImageZone).select(:zone).where(:zone, N::TALIA.component_zone, self).execute
  end
  
  def inherited_iconclasses
    ActiveRDF::Query.new(IconclassTerm).select(:iconclass).where(:card, N::TALIA.parent_card, self).where(:card, N::DCT.subject, :iconclass).execute
  end
  
end