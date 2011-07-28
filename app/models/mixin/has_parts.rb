module Mixin::HasParts
  def parts
    raise Exception, "To use HasPart mixin, class needs to implement a #parts_query method" unless self.respond_to? :parts_query
    self.parts_query.execute
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
    end.flatten
    return self.respond_to?(:image_zone) ? ([self.image_zone] + zones) : zones
  end

  def can_show?(klass)
    klass.respond_to? :showable_in? and klass.showable_in? self.class
  end
end
