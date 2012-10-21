require 'dm-migrations'

# module DataMapper
#   module Migrations
    # module SingletonMethods
    #   def repository_execute(method, repository_name)
    #     models = DataMapper::Model.descendants
    #     puts "model: #{models}"
    #     models = models.select { |m| m.default_repository_name == repository_name } if repository_name
    #     models.each do |model|
    #       puts "model: #{model}"
    #       model.send(method, model.default_repository_name)
    #     end
    #   end
    # 
    # end
    
    # module Repository
    #   def create_model_storage(model)
    #     adapter = self.adapter
    #     puts "creating model #{model} with #{adapter}"
    #     if adapter.respond_to?(:create_model_storage)
    #       ret = adapter.create_model_storage(model)
    #       puts "success: #{ret}"
    #       DataMapper.logger.add(ActiveSupport::BufferedLogger::Severity::INFO, "creating model #{model} #{ret}")
    #     end
    #   end
    # end
  #   module DataObjectsAdapter
  #     def create_model_storage(model)
  #       name = self.name
  #       properties = model.properties_with_subclasses(name)
  # 
  #       return false if storage_exists?(model.storage_name(name))
  #       return false if properties.empty?
  # 
  #       with_connection do |connection|
  #         p connection
  #         statements = [ create_table_statement(connection, model, properties) ]
  #         statements.concat(create_index_statements(model))
  #         statements.concat(create_unique_index_statements(model))
  # 
  #         statements.each do |statement|
  #           #puts "statement: #{statement}"
  #           command = connection.create_command(statement)
  #           command.execute_non_query
  #         end
  #       end
  # 
  #       true
  #     end
  #   end
  # end
  # 
  # module Model
  #   def auto_migrate!(repository_name = self.repository_name)
  #     assert_valid(true)
  #     auto_migrate_down!(repository_name)
  #     auto_migrate_up!(repository_name)
  #     puts "auto_migrate done"
  #   end
  #   
  #   def auto_migrate_up!(repository_name = self.repository_name)
  #     assert_valid(true)
  #     base_model = self.base_model
  #     if base_model == self
  #       puts "base_model == self"
  #       repository(repository_name).create_model_storage(self)
  #     else
  #       puts "auto_migrate_up"
  #       base_model.auto_migrate_up!(repository_name)
  #     end
  #   end
  # end
# end


# Related to http://stackoverflow.com/q/5950238/1749924
namespace :test do
  desc 'DataMapper prep stage: load the test database via desctructive autoupgrade'
  task :prepare => :environment do
    #TODO make sure we're calling the correct DataMapper.setup....
    puts "if this is not test, then rails has already been booted incorrectly: #{Rails.env}"
    Rails.env = 'test'
    #Rake::Task['db:autoupgrade'].invoke
    # Copied from dm-rails/railties/database.rake, but needs to use the current test environment
    
    # puts '----'
    # p ::DataMapper::Model.descendants.entries
    # puts '^^^^'
    ::DataMapper.finalize
    Rails::DataMapper.configuration.repositories[Rails.env].each do |repository, config|
      #p DataMapper.repository.adapter
      ::DataMapper.auto_migrate!(repository.to_sym)
      puts "[datamapper] Finished update for :#{repository} repository '#{config['database']}'"
    end
  end
end
