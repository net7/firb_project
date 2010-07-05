require 'talia_util/rake_tasks'

require 'csv'

namespace :iconclass do
  
  desc 'Import iconclass from CSV dump. Param: csv=<path to csv> [reset=true]'
  task :import => 'talia_core:init' do
    errors = []
    IconclassTerm.destroy_all if(ENV['reset'])
    CSV.open(ENV['csv'], 'r') do |row|
      # puts row.inspect
      begin
        # Ignores the soundex column (row[3])
        IconclassTerm.create_term(:term => row[2], :pref_label => row[1], :alt_label => row[4], :note => row[5]).save!
        print '.'
      rescue Exception => e
        errors << [e, row]
        print 'E'
      end
    end
    puts '*'
    puts 'Done.'
    unless(errors.empty?)
      puts "There were #{errors.size} problems during import:"
      errors.each do |e, row|
        puts "Error with row #{row.inspect}: #{e.message}"
      end
    end
  end
end

namespace :talia_model do 
   
  desc "Rename a talia_source model into the database. Will need another rake task after that to rebuild the RDF. Param: old=<old source name> new=<new source name>. You can specify old_uri and new_uri to change the sources uris as well"
  task :rename => 'talia_core:init' do
    old_name = ENV['old']
    new_name = ENV['new']
    
    query = "UPDATE active_sources SET type='#{new_name}' WHERE type='#{old_name}'"
    puts "@@ Renaming type #{old_name} to #{new_name}. Query: #{query}"
    m = ActiveRecord::Base.connection.execute(query)
    puts "@@ #{m} types modified"
        
    if (!ENV['old_uri'].nil?)
      old_uri = ENV['old_uri']
      new_uri = ENV['new_uri']
      query = "UPDATE active_sources SET uri = replace(uri, '#{old_uri}', '#{new_uri}')"
      
      puts "@@ Renaming URIs #{old_uri} to #{new_uri}. Query: #{query}"
      m = ActiveRecord::Base.connection.execute(query)
      puts "@@ #{m} uris modified"      
    end
  end
  
end

namespace :firb do
  desc "Rename FirbImage, FirbImageZone active sources to Image, ImageZone"
  task :images_rename => 'talia_core:init' do
    ENV = ENV.merge({'old' => 'FirbImage', 'new' => 'Image'})
    Rake::Task['talia_model:rename'].reenable
    Rake::Task['talia_model:rename'].invoke

    ENV = ENV.merge({'old' => 'FirbImageZone', 'new' => 'ImageZone'})
    Rake::Task['talia_model:rename'].reenable
    Rake::Task['talia_model:rename'].invoke
    
    if (ENV['make_all'].nil?)
      Rake::Task['talia_core:rebuild_rdf'].invoke
      Rake::Task['talia_core:setup_ontologies'].invoke
    end
  end

  desc "Rename FirbAnastaticaPage active sources to Anastatica"
  task :anastatica_rename => 'talia_core:init' do
    ENV = ENV.merge({'old' => 'FirbAnastaticaPage', 'new' => 'Anastatica'})
    Rake::Task['talia_model:rename'].reenable
    Rake::Task['talia_model:rename'].invoke

    if (ENV['make_all'].nil?)
      Rake::Task['talia_core:rebuild_rdf'].invoke
      Rake::Task['talia_core:setup_ontologies'].invoke
    end
  end

  desc "Rename Firb*TextCards active source to *TextCards"
  task :text_cards_rename => 'talia_core:init' do

    ENV = ENV.merge({'old' => 'FirbTextCard', 'new' => 'TextCard', 'old_uri' => "firb_text_card", 'new_uri' => 'text_card'})
    Rake::Task['talia_model:rename'].reenable
    Rake::Task['talia_model:rename'].invoke

    # These models used the same firb_text_card uris, so they should already be renamed
    ENV = ENV.merge({'old' => 'FirbPiTextCard', 'new' => 'PiTextCard'})
    Rake::Task['talia_model:rename'].reenable
    Rake::Task['talia_model:rename'].invoke

    ENV = ENV.merge({'old' => 'FirbFiTextCard', 'new' => 'FiTextCard'})
    Rake::Task['talia_model:rename'].reenable
    Rake::Task['talia_model:rename'].invoke

    ENV = ENV.merge({'old' => 'FirbBgTextCard', 'new' => 'BgTextCard'})
    Rake::Task['talia_model:rename'].reenable
    Rake::Task['talia_model:rename'].invoke

    ENV = ENV.merge({'old' => 'FirbVtTextCardHandwritten', 'new' => 'VtHandwrittenTextCard'})
    Rake::Task['talia_model:rename'].reenable
    Rake::Task['talia_model:rename'].invoke

    ENV = ENV.merge({'old' => 'FirbVtTextCardPrinted', 'new' => 'VtPrintedTextCard'})
    Rake::Task['talia_model:rename'].reenable
    Rake::Task['talia_model:rename'].invoke

    if (ENV['make_all'].nil?)
      Rake::Task['talia_core:rebuild_rdf'].invoke
      Rake::Task['talia_core:setup_ontologies'].invoke
    end
  end

  desc "Rename FirbNonIllustratedMemoryDepictionCard to PiNonIllustratedMdCard"
  task :non_illustrated_md_card_rename => 'talia_core:init' do
    ENV = ENV.merge({'old' => 'FirbNonIllustratedMemoryDepictionCard', 'new' => 'PiNonIllustratedMdCard', 'old_uri' => 'firb_non_illustrated_memory_depiction_cards', 'new_uri' => 'pi_non_illustrated_memory_depiction_card'})
    Rake::Task['talia_model:rename'].reenable
    Rake::Task['talia_model:rename'].invoke

    if (ENV['make_all'].nil?)
      Rake::Task['talia_core:rebuild_rdf'].invoke
      Rake::Task['talia_core:setup_ontologies'].invoke
    end
  end

  desc "Rename FirbLetterIllustrationCard to PiLetterIllustrationCard"
  task :letter_illustration_rename => 'talia_core:init' do
    ENV = ENV.merge({'old' => 'FirbLetterIllustrationCard', 'new' => 'PiLetterIllustrationCard', 'old_uri' => 'firb_card', 'new_uri' => 'pi_letter_illustration_card'})
    Rake::Task['talia_model:rename'].reenable
    Rake::Task['talia_model:rename'].invoke

    if (ENV['make_all'].nil?)
      Rake::Task['talia_core:rebuild_rdf'].invoke
      Rake::Task['talia_core:setup_ontologies'].invoke
    end
  end

  desc "Rename FirbParentIllustrationCard to PiIllustrationCard"
  task :parent_illustration_rename => 'talia_core:init' do
    ENV = ENV.merge({'old' => 'FirbParentIllustrationCard', 'new' => 'PiIllustrationCard', 'old_uri' => 'parent_illustration', 'new_uri' => 'pi_illustration_card'})
    Rake::Task['talia_model:rename'].reenable
    Rake::Task['talia_model:rename'].invoke

    if (ENV['make_all'].nil?)
      Rake::Task['talia_core:rebuild_rdf'].invoke
      Rake::Task['talia_core:setup_ontologies'].invoke
    end
  end

  desc "Rename FirbIllustratedMemoryDepictionCard to PiIllustratedMdCard"
  task :illustrated_md_rename => 'talia_core:init' do
     ENV = ENV.merge({'old' => 'FirbIllustratedMemoryDepictionPage', 'new' => 'PiIllustratedMdCard', 'old_uri' => 'firbillustratedmemorydepiction', 'new_uri' => 'pi_illustrated_md_card'})
    Rake::Task['talia_model:rename'].reenable
    Rake::Task['talia_model:rename'].invoke

    if (ENV['make_all'].nil?)
      Rake::Task['talia_core:rebuild_rdf'].invoke
      Rake::Task['talia_core:setup_ontologies'].invoke
    end
  end

  desc "Rename FirbNotes active sources to Note"
  task :notes_rename => 'talia_core:init' do
    ENV = ENV.merge({'old' => 'FirbNote', 'new' => 'Note', 'old_uri' => 'firbnote', 'new_uri' => 'note'})
    Rake::Task['talia_model:rename'].reenable
    Rake::Task['talia_model:rename'].invoke

    if (ENV['make_all'].nil?)
      Rake::Task['talia_core:rebuild_rdf'].invoke
      Rake::Task['talia_core:setup_ontologies'].invoke
    end
  end

  desc "Rename FirbParadeCartCard to FiParadeCartCard"
  task :notes_rename => 'talia_core:init' do
    ENV = ENV.merge({'old' => 'FirbParadeCartCard', 'new' => 'FiParadeCartCard', 'old_uri' => 'parade_cart', 'new_uri' => 'fi_parade_cart_card'})
    Rake::Task['talia_model:rename'].reenable
    Rake::Task['talia_model:rename'].invoke

    if (ENV['make_all'].nil?)
      Rake::Task['talia_core:rebuild_rdf'].invoke
      Rake::Task['talia_core:setup_ontologies'].invoke
    end
  end

  desc "Rename FirbParadeCharacterCard to FiCharacterCard"
  task :notes_rename => 'talia_core:init' do
    ENV = ENV.merge({'old' => 'FirbParadeCharacterCard', 'new' => 'FiCharacterCard', 'old_uri' => 'parade_character', 'new_uri' => 'fi_character_card'})
    Rake::Task['talia_model:rename'].reenable
    Rake::Task['talia_model:rename'].invoke

    if (ENV['make_all'].nil?)
      Rake::Task['talia_core:rebuild_rdf'].invoke
      Rake::Task['talia_core:setup_ontologies'].invoke
    end
  end

  desc "Rename Procession to FiProcession"
  task :notes_rename => 'talia_core:init' do
    ENV = ENV.merge({'old' => 'Procession', 'new' => 'FiProcession', 'old_uri' => 'procession', 'new_uri' => 'fi_procession'})
    Rake::Task['talia_model:rename'].reenable
    Rake::Task['talia_model:rename'].invoke

    if (ENV['make_all'].nil?)
      Rake::Task['talia_core:rebuild_rdf'].invoke
      Rake::Task['talia_core:setup_ontologies'].invoke
    end
  end

  desc "Rename Parade to FiParade"
  task :notes_rename => 'talia_core:init' do
    ENV = ENV.merge({'old' => 'Parade', 'new' => 'FiParade', 'old_uri' => 'parade', 'new_uri' => 'fi_parade'})
    Rake::Task['talia_model:rename'].reenable
    Rake::Task['talia_model:rename'].invoke

    if (ENV['make_all'].nil?)
      Rake::Task['talia_core:rebuild_rdf'].invoke
      Rake::Task['talia_core:setup_ontologies'].invoke
    end
  end

  desc "Rename all the Firb* models to the news names"
  task :rename_all => 'talia_core:init' do
    ENV['make_all'] = 'something'
    Rake::Task['firb:images_rename'].reenable
    Rake::Task['firb:images_rename'].invoke

    Rake::Task['firb:anastatica_rename'].reenable
    Rake::Task['firb:anastatica_rename'].invoke    

    Rake::Task['firb:text_cards_rename'].reenable
    Rake::Task['firb:text_cards_rename'].invoke    

    Rake::Task['firb:notes_rename'].reenable
    Rake::Task['firb:notes_rename'].invoke

    Rake::Task['firb:parent_illustration_rename'].reenable
    Rake::Task['firb:parent_illustration_rename'].invoke

    Rake::Task['firb:letter_illustration_rename'].reenable
    Rake::Task['firb:letter_illustration_rename'].invoke

    Rake::Task['firb:non_illustrated_md_card_rename'].reenable
    Rake::Task['firb:non_illustrated_md_card_rename'].invoke

    Rake::Task['firb:illustrated_md_rename'].reenable
    Rake::Task['firb:illustrated_md_rename'].invoke

    Rake::Task['talia_core:rebuild_rdf'].invoke
    Rake::Task['talia_core:setup_ontologies'].invoke
  end

end