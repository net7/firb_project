require File.dirname(__FILE__) + '/../test_helper'

class FakeSourceTest < ActiveSupport::TestCase
  
  include TaliaUtil::TestHelpers
  suppress_fixtures
  
  def setup
    setup_once(:flush) do
      TaliaUtil::Util.flush_db
      TaliaUtil::Util.flush_rdf
      true
    end
    setup_once(:fake_source) do
      source = TaliaSource.new
      source.uri = "http://faketest/fakesource"
      source.save!
      source.real_source[N::TALIA.testpred] << 'foo'
      source.save!
      TaliaSource.find(source.id)
    end
    setup_once(:real_source) do
      source = TaliaCore::Source.new('http://faketest/realsource')
      source[N::TALIA.testpred] << 'foo'
      source.save!
      TaliaCore::ActiveSource.find(source.uri)
    end
    setup_once(:fake_collection) do
      collection = TaliaCollection.new
      collection.uri = "http://faketest/fakecollection"
      collection.save!
      collection.real_source << @real_source
      collection.save!
      TaliaCollection.find(collection.id)
    end
    setup_once(:real_collection) do
      collection = TaliaCore::Collection.new('http:://faketest/realcollection')
      collection << @real_source
      collection.save!
      TaliaCore::Collection.find(collection.uri)
    end
  end
  
  
  def test_predicate_standard
    assert_equal(@fake_source.real_source[N::TALIA.testpred].send(:items).collect { |i| i.value }, @real_source[N::TALIA.testpred].send(:items).collect { |i| i.value })
  end
  
  def test_rdf_matching
    real_result = ActiveRDF::Query.new(N::URI).select(:predicate, :object).where(@real_source, :predicate, :object).execute
    fake_result = ActiveRDF::Query.new(N::URI).select(:predicate, :object).where(@fake_source.to_uri, :predicate, :object).execute
    assert_equal(real_result, fake_result)
  end
  
  def test_collection_standard
    assert_equal(@real_collection.elements, @fake_collection.real_source.elements)
  end
  
  def test_rdf_collection
    real_result = ActiveRDF::Query.new(N::URI).select(:predicate, :object).where(@real_collection, :predicate, :object).execute
    fake_result = ActiveRDF::Query.new(N::URI).select(:predicate, :object).where(@fake_collection.to_uri, :predicate, :object).execute
    assert_equal(real_result, fake_result)
  end
  
end