# Represent a Parade (Sfilata) in the FIRB FI site
class Parade < TaliaCore::Collection
  hobo_model # Don't put anything above this
  validate :only_processions
  
  include StandardPermissions
  extend RdfProperties
  
  autofill_uri :force => true
  declare_attr_type :name, :string
  declare_attr_type :title, :string
  
  def name
    title.blank? ? uri.local_name : title
  end
  
  private
  
  def only_processions
    ordered_objects.each do |element|
      errors.add_to_base("Illegal type for #{element.inspect}: #{element.class.name}") unless(element.is_a?(FiProcession))
    end
  end

end