
# Related to http://stackoverflow.com/q/5950238/1749924
namespace :test do
  desc 'DataMapper prep stage: load the test database via desctructive autoupgrade'
  #task :prepare => ['db:autoupgrade']
  task :prepare => :environment do
    Rails.env = 'test'
    Rake::Task['db:autoupgrade'].invoke
    # Copied from dm-rails/railties/database.rake, but needs to use the current test environment
    # require 'dm-migrations'
    # puts "RAILS_ENV is #{RAILS_ENV}"
    # puts "env: #{Rails.env}"
    # Rails::DataMapper.configuration.repositories[Rails.env].each do |repository, config|
    #   ::DataMapper.auto_upgrade!(repository.to_sym)
    #   puts "[datamapper] Finished auto_upgrade! for :#{repository} repository '#{config['database']}'"
    # end
  end
end