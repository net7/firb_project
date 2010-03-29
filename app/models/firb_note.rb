class FirbNote < TaliaCore::Source
  hobo_model # Don't put anything above this
  include StandardPermissions

  singular_property :text_page, N::DCT.isPartOf

  fields do
    uri :string
  end

  def self.create_note(text_page)
    n = FirbNote.new(N::LOCAL + 'firbnote/' + FirbImageElement.random_id)
    p = FirbTextPage.find(text_page)
    n.text_page = p
    n
  end

end