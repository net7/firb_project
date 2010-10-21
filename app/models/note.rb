class Note < TaliaCore::Source
  hobo_model # Don't put anything above this
  include StandardPermissions

  singular_property :text_card, N::DCT.isPartOf
  singular_property :content, N::TALIA.content

  fields do
    uri :string
  end

  declare_attr_type :content, :text

  def self.create_note(content, text_card)
    n = Note.new(N::LOCAL + 'note/' + ImageElement.random_id)
    n.content = content
    p = TaliaCore::ActiveSource.find(text_card)
    n.text_card = p
    n
  end

  def self.create_notes(notes, text_card)
    notes.each{ |n| 
      new_note = Note.create_note(n, text_card)
      new_note.save!
    }
  end

  def self.replace_notes(new_notes, text_card)

    old_notes_uris = text_card.notes.collect { |o| o.uri.to_s }
    new_notes_uris = new_notes.collect { |uri, v| uri.to_s }
    old_notes_uris.each { |old| 
      if (!new_notes_uris.include?(old))
        note = Note.find(old)
# TODO: the next line gives error, sine the .remove method doesn't exist
#       do we really need something like that? isn't the following destroy enough?
#        note[N::DCT.isPartOf].remove(text_card)
        note.destroy
      end
    }

    new_notes.each { |key, value|
        if (key.match("new."))
          new_note = Note.create_note(value, text_card)
          new_note.save!
        else
          Note.update_note(key, value)
        end
    }
  end

  def self.update_note(uri, content)
    n = Note.find(uri)
    n.content = content
    n.save!
  end

  def self.delete_all_notes(text_card)
    qry = ActiveRDF::Query.new(Note).select(:note).distinct
    qry.where(:note, N::DCT.isPartOf, text_card)
    old_notes = qry.execute
    old_notes.each { |n| 
# TODO: the next line gives error, sine the .remove method doesn't exist
#       do we really need something like that? isn't the following destroy enough?
#        n[N::DCT.isPartOf].remove(text_card)
        n.destroy
    }
  end

end