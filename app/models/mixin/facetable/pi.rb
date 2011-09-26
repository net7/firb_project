module Mixin::Facetable::Pi

  include Mixin::Facetable

  protected
    def facets_allowed_predicates
      [N::FIRBSWN.hasNote.to_s, N::FIRBSWN.instanceOf.to_s, N::FIRBSWN.hasMemoryDepiction.to_s]
    end
  # end protected
end # module Mixin::Facetable:Pi
