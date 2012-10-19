require 'rails'
require 'active_model/railtie'

# Comment taken from active_record/railtie.rb
#
# For now, action_controller must always be present with
# rails, so let's make sure that it gets required before
# here. This is needed for correctly setting up the middleware.
# In the future, this might become an optional require.
require 'action_controller/railtie'

module Rails
  module DataMapper
    class DmFixtureRailtie < Rails::Railtie
      rake_tasks do
        # path = File.join(File.dirname(__FILE__), 'tasks', '*.rake')
        # puts "here" + path
        # Dir[path].each { |f| load f }
        load 'dm-fixture/railties/testing.rake'
      end
    end
  end
end
