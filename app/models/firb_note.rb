class FirbNote < TaliaCore::Source
  hobo_model # Don't put anything above this
  include StandardPermissions

  singular_property :text_page, N::DCT.isPartOf

  fields do
    uri :string
  end

  def self.create_note(notes, text_page)
    n = FirbNote.new(N::LOCAL + 'firbnote/' + FirbImageElement.random_id)
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