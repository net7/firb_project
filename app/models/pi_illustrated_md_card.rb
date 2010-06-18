class PiIllustratedMdCard < IllustrationCard
  
  include StandardPermissions
  
  autofill_uri :force => true
  
  # Short description: brief desc. of the depiction, say "Male person
  # drawing"
  singular_property :short_description, N::TALIA.short_description
  declare_attr_type :short_description, :text
  singular_property :transcription_text, N::TALIA.transcription
  declare_attr_type :transcription_text, :text
  singular_property :parent_card, N::TALIA.parent_card, :force_relation => true
  singular_property :content_type, N::DCT.type

  # Still missing:
  # textual source: link to a text page
  # links to component depictions pages
  
end