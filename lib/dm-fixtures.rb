# A rip of some of ActiveRecord's fixtures helpers, ported to DataMapper. For the conservative/slow adopters of dm-sweatshop.
# 
# Author:: Phill Baker
# Copyright:: Copyright (c) 2012 Phill Baker
# License:: MIT License (http://www.opensource.org/licenses/mit-license.php)

require 'dm-core'
require 'adapters'
require 'dm-fixtures/fixtures'
require 'dm-fixtures/railtie'

if defined?(DataMapper)
  # Follow ActiveRecord's model, put this in a pre-run rake task, just like starting the server
  # p DataMapper::Model.descendants.entries #TODO below doesn't work because model classes aren't required? => they are in rails init...
  # DataMapper.auto_migrate! # Get the database set up
  
  class ActiveSupport::TestCase
    include DataMapper::TestFixtures
    self.fixture_path = "#{Rails.root}test/fixtures/"
  end

  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path

  def create_fixtures(*fixture_set_names, &block)
    FixtureSet.create_fixtures(ActiveSupport::TestCase.fixture_path, fixture_set_names, {}, &block)
  end
end