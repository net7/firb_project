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
      new_note = FirbNote.create_note(n, text_page)
      new_note.save!
    }
  end

  def self.replace_notes(new_notes, text_page)

    old_notes_uris = text_page.notes.collect { |o| o.uri.to_s }
    new_notes_uris = new_notes.collect { |uri, v| uri }
    old_notes_uris.each { |old| 
      if (!new_notes_uris.include?(old))
        old[N::DCT.isPartOf].remove(text_page)
        old.destroy
      end
    }

    new_notes.each { |key, value|
        if (key.match("new."))
          new_note = FirbNote.create_note(value, text_page)
          new_note.save!
        else
          FirbNote.update_note(key, value)
        end
    }
  end

  def self.update_note(uri, content)
    n = FirbNote.find(uri)
    n.content = content
    n.save!
  end

  def self.delete_all_notes(text_page)
    qry = ActiveRDF::Query.new(FirbNote).select(:note).distinct
    qry.where(:note, N::DCT.isPartOf, text_page)
    old_notes = qry.execute
    old_notes.each { |n| 
        n[N::DCT.isPartOf].remove(text_page)
        n.destroy
    }
  end

end