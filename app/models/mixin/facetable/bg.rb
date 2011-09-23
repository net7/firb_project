module Mixin::Facetable::Bg

  include Mixin::Facetable

  protected

    def facets_allowed_predicates
      [N::FIRBSWN.keywordForImageZone]
    end
  # end protected
end # module Mixin::Facetable:Bg
