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
  
  def test_term
    assert_equal('61E(+0)', @term.term)
  end
  
  def test_name
    assert_equal(@term.term, @term.name)
  end
  
  def test_find_by_term
    termy = IconclassTerm.create_term(:term => '61 E (+1)', 
      :pref_label => 'foo', 
      :alt_label => 'bar',
      :soundex => 'meep',
      :note => 'ping'
      )
    termy.save!
    assert_equal(termy, IconclassTerm.find('61E(+1)'))
  end
  
  def test_create_blank
    no_note = IconclassTerm.create_term(:term => '61 E (+0)', 
      :pref_label => 'foo', 
      :alt_label => 'bar',
      :soundex => 'meep',
      :note => ''
      )
    no_note.save!
    assert_equal(nil, no_note.note)
  end
  
end