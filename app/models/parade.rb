# Represent a Parade (Sfilata) in the FIRB FI site
class Parade < TaliaCore::Collection
  hobo_model # Don't put anything above this
  validate :only_carts_and_characters
  
  include StandardPermissions
  extend RdfProperties
  
  autofill_uri
  
  multi_property :processions, N::TALIA.hasProcession, :force_relation => true, :dependent => :destroy
  
  def characters
    ordered_objects.find_all { |el| el.is_a?(ParadeCharacter) }
  end
  
  def carts
    ordered_objects.find_all { |el| el.is_a?(ParadeCart) }
  end
  
  def add_procession(options)
    options.to_options!
    procession = ParadeProcess.new(options)
    procession.save!
    processions << procession
  end
  
  # Returns the parade, grouped by the processions. This returns an array
  # which contains a sub-array for each procession, with the procession object
  # as its first element and an array with the procession elements as the second
  # element
  #
  # Members of the paraded not in any procession are directly added to the 
  # result array
  def grouped_by_processions
    grouped_parade = []
    current_index = 0
    procession_list.each do |first, last, procession|
      grouped_parade += ordered_elements[current_index..first]
      grouped_parade << [procession, ordered_elements[first..last]]
      current_index = last
    end
    grouped_parade += ordered_elements[last..-1]
    grouped_parade
  end
  
  private
  
  # Get an ordered list of all the processions in the parade
  def procession_list
    my_processions = processions.collect do |proces|
      first_id, last_id = nil, nil
      ordered_elements.each_with_index do |el, idx|
        first_id = idx if(el.uri == proces.first_member.uri)
        last_id = idx if(el.uri == proces.last_member.uri)
      end
      next unless(first_id && last_id && (first_id < last_id))
      [ first_id, last_id, proces ]
    end
    my_processions.sort { |a,b| a.first <=> b.first }
    my_processions
  end
  
  def only_carts_and_characters
    ordered_objects.each do |element|
      errors.add_to_base("Illegal type for #{element.uri}") unless(element.is_a?(ParadeCart) || element.is_a?(ParadeCharacter))
    end
  end
end