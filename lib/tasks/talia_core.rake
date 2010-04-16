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