require File.dirname(__FILE__) + '/../test_helper'

class IconclassTermTest < ActiveSupport::TestCase
  
  include TaliaUtil::TestHelpers
  suppress_fixtures
  
  def setup
    setup_once(:flush) do
      TaliaUtil::Util.flush_db
      TaliaUtil::Util.flush_rdf
      true
    end
    setup_once(:term) do
      IconclassTerm.create_term(:term => '61 E (+0)', 
        :pref_label => 'foo', 
        :alt_label => 'bar',
        :soundex => 'meep',
        :note => 'Cool'
        )
    end
  end
  
  def test_uri
    assert_equal('http://www.iconclass.org/rkd/61E%28%2B0%29/'.to_uri, @term.uri)
  end
  
  def test_pref_label
    assert_equal('foo', @term.pref_label)
  end
  
  def test_alt_label
    assert_equal('bar', @term.alt_label)
  end
  
  def test_soundex
    assert_equal('meep', @term.soundex)
  end
  
  def test_note
    assert_equal('Cool', @term.note)
  end
  
end