class TaliaCollection < ActiveRecord::Base
  hobo_model # Don't put anything above this
  
  include StandardPermissions
  include FakeSource
  extend FakeSource::ClassMethods
  
  set_table_name "active_sources"
  has_real_class TaliaCore::Collection
  
  self.inheritance_column = 'foo'
  
  fields do
    uri :string
  end
  declare_attr_type :name, :string
  
end