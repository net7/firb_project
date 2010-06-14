require File.dirname(__FILE__) + '/../test_helper'

class FirbIllustrationCardTest < ActiveSupport::TestCase
  
  include TaliaUtil::TestHelpers
  suppress_fixtures
  
  def setup
    setup_once(:flush) do
      TaliaUtil::Util.flush_db
      TaliaUtil::Util.flush_rdf
      true
    end
    
    setup_once(:iconclasses) do
      iconclasses = []
      (0..1).each do |idx|
        iconclass = IconclassTerm.create_term(:term => "61 E (+#{idx})", 
          :pref_label => 'foo', 
          :alt_label => 'bar',
          :soundex => 'meep',
          :note => 'Cool' )
        iconclass.save!
        iconclasses << iconclass
      end
      iconclasses
    end
    
    setup_once(:image_zone) do
      zone = ImageZone.create_with_name('hello')
      zone.save!
      zone
    end
    
    assert_equal(2, @iconclasses.size)
    
    
    setup_once(:components) do
      (1..2).collect do |idx|
        comp = ImageComponent.new(:name => "FOO#{idx}", :zone_type => "BAR", :image_zone => @image_zone)
        comp.save!
        comp
      end
    end
    
    setup_once(:card) do
      source = FirbIllustrationCard.new(
      :name => "illustration",
      :image_zone => @image_zone.uri,
      :iconclass_terms => @iconclasses.collect { |ic| ic.uri.to_s },
      :image_components => @components.collect { |comp| { :uri => comp.uri.to_s } }
      )
      
      source.save!
      source
    end
    
    assert_not_nil(@card)
  end

  def test_image_zone
    assert_equal(@card.image_zone.uri, @image_zone.uri)
  end
  
  def test_iconclasses
    assert_equal(2, @card.iconclass_terms.size)
  end
  
  def test_components
    assert_equal(2, @card.image_components.size)
  end
  
  def test_create_components
    assert_difference("ImageComponent.count", 1) do
      card =  FirbIllustrationCard.new(:name => "compy test",
        :image_zone => @image_zone.uri,
        :image_components => [{ :uri => @components.first.uri.to_s },{
          :name => "FOOX", :zone_type => "BAR", :image_zone => @image_zone
      }])
      card.save!
    end
  end
  
  def test_rewrite_attributes
    source = FirbIllustrationCard.new(
    :name => "illustrationx"
    )
    source.save!
    new_find = FirbIllustrationCard.find(source.id)
    new_find.rewrite_attributes!(
    :name => "illustrationY",
    :image_zone => @image_zone.uri,
    :iconclass_terms => @iconclasses.collect { |ic| ic.uri.to_s }
    )
    new_card = FirbIllustrationCard.find(source.id)
    assert_equal('illustrationY', new_card.name)
    assert_equal(new_card.image_zone.uri, @image_zone.uri)
    assert_equal(2, new_card.iconclass_terms.size)
  end
  
end