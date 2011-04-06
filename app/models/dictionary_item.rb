class DictionaryItem < TaliaCore::Source

  hobo_model # Don't put anything above this

  include StandardPermissions
  extend RdfProperties

  autofill_uri :force => true

  rdf_property :name, N::TALIA.name, :type => :string
  rdf_property :item_type, N::TALIA.dictionary_item_type, :type => :string
  rdf_property :comment, N::TALIA.dictionary_item_comment, :type => :text

end