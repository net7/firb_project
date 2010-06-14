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
    puts "@@ Submitting query: #{query}"
    m = ActiveRecord::Base.connection.execute(query)
    puts "@@ Modified #{m} rows"
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
    
    Rake::Task['talia_core:rebuild_rdf'].invoke
  end

end