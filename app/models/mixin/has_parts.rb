##
# Every model including this mixin MUST implement a parts_query method:
# #parts_query should return an ActiveRDF::Query object to use to recover the model's parts
# (or nil if there are none, or cannot be retrieved with a query).
#
# Every model including this mixin CAN implement an additional_parts method:
# #additional_parts should return an array (or equivalent) of parts that could not be retreived with the query from #parts_query.
module Mixin::HasParts
  def parts
    raise Exception, "To use HasPart mixin, class needs to implement a #parts_query method" unless self.respond_to? :parts_query
    parts = self.parts_query.nil? ? [] : self.parts_query.execute
    parts += self.additional_parts.to_a if self.respond_to? :additional_parts
    parts
  end

  # Parts grouped by class
  def parts_by_class
    part_hash = {}
    my_parts = parts
    my_parts.each do |part|
      part_hash[part.class.name] ||= []
      part_hash[part.class.name] << part
    end
    part_hash
  end

  def showable_parts
    @showable_parts ||= Hash[parts_by_class.select do |k,v|
                               self.can_show?(v.first.class)
                             end]
  end

  def showable_zones
    zones = showable_parts.values.flatten.map do |z|
      z.respond_to?(:image_zones) ? z.image_zones.to_a : z.image_zone
    end.flatten.uniq
    return self.respond_to?(:image_zone) ? ([self.image_zone] + zones) : zones
  end

  def can_show?(klass)
    klass.respond_to? :showable_in? and klass.showable_in? self.class
  end
end
