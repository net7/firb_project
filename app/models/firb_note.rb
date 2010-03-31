class FirbNote < TaliaCore::Source
  hobo_model # Don't put anything above this
  include StandardPermissions

  singular_property :text_page, N::DCT.isPartOf
  singular_property :content, N::TALIA.content

  fields do
    uri :string
  end

  declare_attr_type :content, :text

  def self.create_note(content, text_page)
    n = FirbNote.new(N::LOCAL + 'firbnote/' + FirbImageElement.random_id)
    n.content = content
    p = FirbTextPage.find(text_page)
    n.text_page = p
    n
  end

  def self.create_notes(notes, text_page)
    notes.each{ |n| 
      new_note = self.create_note(n, text_page)
      new_note.save
    }
  end

end