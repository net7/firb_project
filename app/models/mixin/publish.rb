module Mixin::Publish
  
  module PublishProperties
    
    def setup_publish_properties
      rdf_property :is_public, N::TALIA.is_public, :type => :boolean
      rdf_property :published_by, N::TALIA.published_by, :type => :string
      rdf_property :published_on, N::DCT.date
    end
    
  end

  def toggle_published_by(user)
    self.published_on = Time.now.to_s
    self.published_by = user
    if (self.is_public?)
      self.unpublish_by(user)
    else
      self.publish_by(user)
    end
  end

  def publish_by(user)
    self.is_public = true
    self.save!
  end

  def unpublish_by(user)
    self.is_public = false
    self.save!
  end

  def is_public?
    self.is_public
  end
  
end