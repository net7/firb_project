module Mixin::Facetable::Fi

  include Mixin::Facetable

  protected

    def facets_allowed_predicates
      [N::FIRBSWN.hasNote.to_s]
    end
  # end protected
end # module Mixin::Facetable::Fi
