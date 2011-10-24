class Note < TaliaCore::Source
  hobo_model # Don't put anything above this
  include StandardPermissions
  extend RdfProperties
  extend Mixin::Showable
  showable_in FiDeityCard, FiAnimalCard, FiVehicleCard, FiThroneCard, FiCharacterCard


  singular_property :text_card, N::DCT.isPartOf
  rdf_property :content, N::TALIA.content, :type => :text
  rdf_property :name, N::TALIA.name, :type => :string
  rdf_property :image_zone, N::TALIA.image_zone, :type => TaliaCore::ActiveSource


  
  after_save :clear_cached_fragments

  def clear_cached_fragments 
    ActionController::Base.new.expire_fragment('note_image_zone', options = nil)
  end 



  fields do
    uri :string
  end

  def self.create_note(source_uri, content, name, image_zone)
    n = Note.new(N::LOCAL + 'note/' + ImageElement.random_id)
    n.content = content
    n.name = name
    n.image_zone = TaliaCore::ActiveSource.find(image_zone) unless (!image_zone)
    p = TaliaCore::ActiveSource.find(source_uri)
    n.text_card = p
    n
  end

  def self.create_notes(source_uri, notes)
    notes.each { |note| 
      new_note = Note.create_note(source_uri, note[:content], note[:name], note[:image_zone])
      new_note.save!
    }
  end

  def self.replace_notes(new_notes, text_card)
    old_notes_uris = text_card.notes.collect { |o| o.uri.to_s }
    new_notes_uris = new_notes.collect { |n| n[:uri] }
    old_notes_uris.each { |old| 
      if (!new_notes_uris.include?(old))
        note = Note.find(old)
        note.destroy
      end
    }
    
    new_notes.each do |note|
        if (note[:uri].match("new."))
          new_note = Note.create_note(text_card, note[:content], note[:name], note[:image_zone])
          new_note.save!
        else
          Note.update_note(note[:uri], note[:content], note[:name], note[:image_zone])
        end
    end
  end

  def self.update_note(uri, content, name, image_zone)
    n = Note.find(uri)
    n.content = content
    n.name = name
    n.image_zone = TaliaCore::ActiveSource.find(image_zone) unless(!image_zone)
    n.save!
  end

  def self.delete_all_notes(text_card)
    qry = ActiveRDF::Query.new(Note).select(:note).distinct
    qry.where(:note, N::DCT.isPartOf, text_card)
    old_notes = qry.execute
    old_notes.each { |n| n.destroy }
  end

end
