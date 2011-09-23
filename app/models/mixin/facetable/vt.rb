module Mixin::Facetable::Vt

  include Mixin::Facetable

  protected

    def facets_allowed_predicates
      [N::FIRBSWN.hasNote.to_s, N::FIRBSWN.instanceOf.to_s]
    end
  # end protected
end # module Mixin::Facetable::Vt
