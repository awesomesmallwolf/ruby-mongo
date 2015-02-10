$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

MODELS = File.join(File.dirname(__FILE__), "app/models")
$LOAD_PATH.unshift(MODELS)

if ENV["CI"]
  require "coveralls"
  Coveralls.wear! do
    add_filter "spec"
  end
end

require "action_controller"
require "mongoid"
require "rspec"
require "helpers"

# These environment variables can be set if wanting to test against a database
# that is not on the local machine.
ENV["MONGOID_SPEC_HOST"] ||= "127.0.0.1"
ENV["MONGOID_SPEC_PORT"] ||= "27017"

# These are used when creating any connection in the test suite.
HOST = ENV["MONGOID_SPEC_HOST"]
PORT = ENV["MONGOID_SPEC_PORT"].to_i

Mongo::Logger.logger.level = Logger::INFO
# Mongoid.logger.level = Logger::DEBUG

# When testing locally we use the database named mongoid_test. However when
# tests are running in parallel on Travis we need to use different database
# names for each process running since we do not have transactions and want a
# clean slate before each spec run.
def database_id
  "mongoid_test"
end

def database_id_alt
  "mongoid_test_alt"
end

require 'support/authorization'

# Give MongoDB time to start up on the travis ci environment.
if (ENV['CI'] == 'travis')
  starting = true
  client = Mongo::Client.new(['127.0.0.1:27017'])
  while starting
    begin
      client.command(Mongo::Server::Monitor::STATUS)
      break
    rescue Mongo::Error::CommandFailure => e
      sleep(2)
      client.cluster.scan!
    end
  end
end

CONFIG = {
  sessions: {
    default: {
      database: database_id,
      hosts: [ "#{HOST}:#{PORT}" ],
      options: {
        server_selection_timeout: 0.5,
        max_pool_size: 1,
        user: MONGOID_TEST_USER.name,
        password: MONGOID_TEST_USER.password
      }
    }
  }
}

# Can we connect to MongoHQ from this box?
def mongohq_connectable?
  ENV["MONGOHQ_REPL_PASS"].present?
end

def purge_database_alt!
  session = Mongoid::Sessions.default
  session.use(database_id_alt)
  session.collections.each do |collection|
    collection.drop
  end
end

def mongodb_version
  session = Mongoid::Sessions.default
  session.command(buildinfo: 1).first["version"]
end

# Set the database that the spec suite connects to.
Mongoid.configure do |config|
  config.load_configuration(CONFIG)
end

# Autoload every model for the test suite that sits in spec/app/models.
Dir[ File.join(MODELS, "*.rb") ].sort.each do |file|
  name = File.basename(file, ".rb")
  autoload name.camelize.to_sym, name
end

module Rails
  class Application
  end
end

module MyApp
  class Application < Rails::Application
  end
end

ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular("canvas", "canvases")
  inflect.singular("address_components", "address_component")
end

I18n.config.enforce_available_locales = false

RSpec.configure do |config|
  config.include Mongoid::SpecHelpers
  config.raise_errors_for_deprecations!

  config.before(:suite) do
    client = Mongo::Client.new(["#{HOST}:#{PORT}"])
    begin
      # Create the root user administrator as the first user to be added to the
      # database. This user will need to be authenticated in order to add any
      # more users to any other databases.
      client.database.users.create(MONGOID_ROOT_USER)
    rescue Exception => e
    end
    begin
      # Adds the test user to the test database with permissions on all
      # databases that will be used in the test suite.
      client.with(
        user: MONGOID_ROOT_USER.name,
        password: MONGOID_ROOT_USER.password
      ).database.users.create(MONGOID_TEST_USER)
    rescue Exception => e
      # If we are on versions less than 2.6, we need to create a user for
      # each database, since the users are not stored in the admin database
      # but in the system.users collection on the datbases themselves. Also,
      # roles in versions lower than 2.6 can only be strings, not hashes.
      unless client.cluster.servers.first.features.write_command_enabled?
        begin
          client.with(
            user: MONGOID_ROOT_USER.name,
            password: MONGOID_ROOT_USER.password,
            auth_source: Mongo::Database::ADMIN,
            database: database_id
          ).database.users.create(MONGOID_LEGACY_TEST_USER)
        rescue Exception => e
        end
      end
    end
  end

  # Drop all collections and clear the identity map before each spec.
  config.before(:each) do
    Mongoid.purge!
  end

  # Filter out MongoHQ specs if we can't connect to it.
  config.filter_run_excluding(config: ->(value){
    return true if value == :mongohq && !mongohq_connectable?
  })
end
