require 'sunspot'
Sunspot.config.solr.url = 'http://localhost:8080/solr_vt'

require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'solr', 'adapters')

Sunspot::Adapters::InstanceAdapter.register(SunspotAdapters::Instance, SOLR::Base)
Sunspot::Adapters::DataAccessor.register(SunspotAdapters::DataAccessor, SOLR::Base)
