class TaliaSource < ActiveRecord::Base
  hobo_model # Don't put anything above this
  
  include StandardPermissions
  include FakeSource
  extend FakeSource::ClassMethods
  
  after_save :save_real_source
  
  self.inheritance_column = 'foo'
  
  fields do
    uri :string
    type :string
  end
  
  set_table_name "active_sources"
  declare_attr_type :name, :string
  
end
