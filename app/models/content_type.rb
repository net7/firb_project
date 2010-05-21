class ContentType < TaliaCore::Source
  
  def self.create_type(type)
    self.new(N::TALIA + type.camelize)
  end
  
  def type
    uri.local_name
  end
  
end