# Include the default permissions for the backend elements
module StandardPermissions
  
  def create_permitted?
    puts "CHECKING CREATE #{acting_user.inspect}"
    acting_user.administrator?
  end
  
  def update_permitted?
    acting_user.administrator?
  end
  
  def view_permitted?(field)
    acting_user.signed_up?
  end
  
end