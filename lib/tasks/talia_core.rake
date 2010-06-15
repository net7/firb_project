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
        IconclassTerm.create_term(:term => row[2], :pref_label => row[1], :alt_label => row[4], :soundex => row[3], :note => row[5]).save!
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
   
  desc "Rename a talia_source model into the database. Will need another rake task after that to rebuild the RDF. Param: old=<old source name> new=<new source name>"
  task :rename => 'talia_core:init' do
    old_name = ENV['old']
    new_name = ENV['new']
    
    query = "UPDATE active_sources SET type='#{new_name}' WHERE type='#{old_name}'"
    puts "@@ Renaming #{old_name} to #{new_name}. Query: #{query}"
    m = ActiveRecord::Base.connection.execute(query)
    puts "@@ #{m} rows modified"
  end
  
end

namespace :firb do
  desc "Rename FirbImage, FirbImageZone active sources to Image, ImageZone"
  task :images_rename => 'talia_core:init' do
    ENV['old'] = 'FirbImage'
    ENV['new'] = 'Image'
    Rake::Task['talia_model:rename'].reenable
    Rake::Task['talia_model:rename'].invoke

    ENV['old'] = 'FirbImageZone'
    ENV['new'] = 'ImageZone'
    Rake::Task['talia_model:rename'].reenable
    Rake::Task['talia_model:rename'].invoke
    
    if (ENV['make_all'] != true) do
      Rake::Task['talia_core:rebuild_rdf'].invoke
      Rake::Task['talia_core:setup_ontologies'].invoke
    end
  end

  desc "Rename FirbAnastaticaPage active sources to Anastatica"
  task :anastatica_rename => 'talia_core:init' do
    ENV['old'] = 'FirbAnastaticaPage'
    ENV['new'] = 'Anastatica'
    Rake::Task['talia_model:rename'].reenable
    Rake::Task['talia_model:rename'].invoke

    if (ENV['make_all'] != true) do
      Rake::Task['talia_core:rebuild_rdf'].invoke
      Rake::Task['talia_core:setup_ontologies'].invoke
    end
  end

  desc "Rename all the Firb* models to the news names"
  task :rename_all => 'talia_core:init' do
    ENV['make_all'] = true
    Rake::Task['firb:images_rename'].reenable
    Rake::Task['firb:images_rename'].invoke

    Rake::Task['firb:anastatica_rename'].reenable
    Rake::Task['firb:anastatica_rename'].invoke    

    Rake::Task['talia_core:rebuild_rdf'].invoke
    Rake::Task['talia_core:setup_ontologies'].invoke
  end

end