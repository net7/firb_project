class TaliaCollection < ActiveRecord::Base

  hobo_model # Don't put anything above this
  
  include StandardPermissions
  include FakeSource
  extend FakeSource::ClassMethods
  extend RandomId
  
  set_table_name "active_sources"
  has_real_class TaliaCore::Collection
  
  self.inheritance_column = 'foo'
  
  def self.create_collection(options)
    options.to_options!
    new_thing = self.new(options)
    new_thing.uri ||= (N::LOCAL.collection + '/' + random_id).to_s
    new_thing.title = options[:title]
    new_thing
  end
  
  fields do
    uri :string
  end
  
  def name
    real_source.title || super
  end
  
  def title
    real_source.title
  end
  
  def title=(value)
    real_source.title = value
  end
  
  declare_attr_type :name, :string
  declare_attr_type :title, :string
  
end