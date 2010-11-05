class Note < TaliaCore::Source
  hobo_model # Don't put anything above this
  include StandardPermissions
  extend RdfProperties

  singular_property :text_card, N::DCT.isPartOf
  rdf_property :content, N::TALIA.content, :type => :text
  rdf_property :name, N::TALIA.name, :type => :string
  rdf_property :image_zone, N::TALIA.image_zone, :type => TaliaCore::ActiveSource

  fields do
    uri :string
  end

  def self.create_note(source_uri, content, name, image_zone)
    n = Note.new(N::LOCAL + 'note/' + ImageElement.random_id)
    n.content = content
    n.name = name
    n.image_zone = TaliaCore::ActiveSource.find(image_zone)
    p = TaliaCore::ActiveSource.find(source_uri)
    n.text_card = p
    n
  end

  def self.create_notes(source_uri, notes)
    puts "111111111111"
    puts notes.inspect
    
    notes.each { |n| 
      new_note = Note.create_note(source_uri, n)
      new_note.save!
    }
  end

  def self.replace_notes(new_notes, text_card)

    puts "ARA ARA ARA new notes" + new_notes.inspect
    
    old_notes_uris = text_card.notes.collect { |o| o.uri.to_s }
    puts "ARA ARA ARA OLD " + old_notes_uris.inspect
    new_notes_uris = new_notes.collect { |n| n[:uri] }
    puts "ARA ARA ARA NEW " + new_notes_uris.inspect
    old_notes_uris.each { |old| 
      if (!new_notes_uris.include?(old))
        note = Note.find(old)
        puts "OCIO OCIO distruggo una nota? :|"
        note.destroy
      end
    }
    
    new_notes.each do |note|
      puts "-------------------- " + note.inspect
        if (note[:uri].match("new."))
          puts "creo una nuova nota?! figata deh .."
          new_note = Note.create_note(text_card, note[:content], note[:name], note[:image_zone])
          puts new_note.inspect
          new_note.save!
        else
          puts "Updated a note? .. e chi lo sa " + note[:uri] + " : " + note[:name]
          Note.update_note(note[:uri], note[:content], note[:name], note[:image_zone])
        end
    end
  end

  def self.update_note(uri, content, name, image_zone)
    puts "OMAGAD updating? :| 1"
    n = Note.find(uri)
    puts "OMAGAD updating? :| 2"
    n.content = content
    puts "OMAGAD updating? :| 3"
    n.name = name
    puts "OMAGAD updating? :| 4"
    n.image_zone = TaliaCore::ActiveSource.find(image_zone)
    puts "OMAGAD updating? :| 5"
    n.save!
    puts "OMAGAD updated? :| 6 last"
  end

  def self.delete_all_notes(text_card)
    qry = ActiveRDF::Query.new(Note).select(:note).distinct
    qry.where(:note, N::DCT.isPartOf, text_card)
    old_notes = qry.execute
    old_notes.each { |n| n.destroy }
  end

end