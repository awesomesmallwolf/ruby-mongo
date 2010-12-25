# encoding: utf-8
require "uri"

module Mongoid #:nodoc

  # This class defines all the configuration options for Mongoid, including the
  # database connections.
  #
  # @todo Durran: This class needs an overhaul, remove singleton, etc.
  class Config < Hash
    include Singleton

    class_inheritable_accessor :options
    self.options = []

    class << self

      # Define a configuration option with a default.
      #
      # @example Define the option.
      #   Config.option(:persist_in_safe_mode, :default => false)
      #
      # @param [ Symbol ] name The name of the configuration option.
      # @param [ Hash ] options Extras for the option.
      #
      # @option options [ Object ] :default The default value.
      #
      # @since 2.0.0.rc.1
      def option(name, options = {})
        self.options << name

        define_method(name) { has_key?(name) ? self[name] : options[:default] }
        define_method("#{name}=") { |value| self[name] = value }
        define_method("#{name}?") { send(name) }
      end
    end

    option :allow_dynamic_fields, :default => true
    option :include_root_in_json, :default => false
    option :parameterize_keys, :default => true
    option :persist_in_safe_mode, :default => false
    option :raise_not_found_error, :default => true
    option :reconnect_time, :default => 3
    option :autocreate_indexes, :default => false
    option :skip_version_check, :default => false
    option :time_zone, :default => nil
    option :logger, :default => defined?(Rails) ? Rails.logger : ::Logger.new($stdout)

    # Adds a new I18n locale file to the load path.
    #
    # @example Add a portuguese locale.
    #   Mongoid::Config.add_language('pt')
    #
    # @example Add all available languages.
    #   Mongoid::Config.add_language('*')
    #
    # @param [ String ] language_code The language to add.
    def add_language(language_code = nil)
      Dir[ File.join(
        File.dirname(__FILE__),
        "..",
        "config",
        "locales",
        "#{language_code}.yml")
      ].each do |file|
        I18n.load_path << File.expand_path(file)
      end
    end

    # Return field names that could cause destructive things to happen if
    # defined in a Mongoid::Document.
    #
    # @example Get the destructive fields.
    #   config.destructive_fields
    #
    # @return [ Array<String> ] An array of bad field names.
    def destructive_fields
      @destructive_fields ||= lambda {
        klass = Class.new do
          include Mongoid::Document
        end
        klass.instance_methods(true).collect { |method| method.to_s }
      }.call
    end

    # Configure mongoid from a hash. This is usually called after parsing a
    # yaml config file such as mongoid.yml.
    #
    # @example Configure Mongoid.
    #   config.from_hash({})
    #
    # @param [ Hash ] settings The settings to use.
    def from_hash(settings)
      settings.except("database", "slaves").each_pair do |name, value|
        send("#{name}=", value) if respond_to?("#{name}=")
      end
      _master(settings)
      _slaves(settings)
    end

    # Sets the Mongo::DB master database to be used. If the object trying to be
    # set is not a valid +Mongo::DB+, then an error will be raised.
    #
    # @example Set the master database.
    #   config.master = Mongo::Connection.db("test")
    #
    # @param [ Mongo::DB ] db The master database.
    #
    # @raise [ Errors::InvalidDatabase ] If the master isnt a valid object.
    #
    # @return [ Mongo::DB ] The master instance.
    def master=(db)
      check_database!(db)
      @master = db
    end
    alias :database= :master=

    # Returns the master database, or if none has been set it will raise an
    # error.
    #
    # @example Get the master database.
    #   config.master
    #
    # @raise [ Errors::InvalidDatabase ] If the database was not set.
    #
    # @return [ Mongo::DB ] The master database.
    def master
      raise Errors::InvalidDatabase.new(nil) unless @master
      if @reconnect
        @reconnect = false
        reconnect!
      end
      @master
    end
    alias :database :master

    # Get the list of defined options in the configuration.
    #
    # @example Get the options.
    #   config.options
    #
    # @return [ Array ] The list of options.
    def options
      self.class.options
    end

    # Convenience method for connecting to the master database after forking a
    # new process.
    #
    # @example Reconnect to the master.
    #   Mongoid.reconnect!
    #
    # @param [ true, false ] now Perform the reconnection immediately?
    def reconnect!(now = true)
      if now
        master.connection.connect
      else
        # We set a @reconnect flag so that #master knows to reconnect the next
        # time the connection is accessed.
        @reconnect = true
      end
    end

    # Reset the configuration options to the defaults.
    #
    # @example Reset the configuration options.
    #   config.reset
    def reset
      options.each { |option| delete(option) }
    end

    # Sets the Mongo::DB slave databases to be used. If the objects provided
    # are not valid +Mongo::DBs+ an error will be raised.
    #
    # @example Set the slaves.
    #   config.slaves = [ Mongo::Connection.db("test") ]
    #
    # @param [ Array<Mongo::DB> ] dbs The slave databases.
    #
    # @raise [ Errors::InvalidDatabase ] If the slaves arent valid objects.
    #
    # @return [ Array<Mongo::DB> ] The slave DB instances.
    def slaves=(dbs)
      return unless dbs
      dbs.each do |db|
        check_database!(db)
      end
      @slaves = dbs
    end

    # Returns the slave databases or nil if none have been set.
    #
    # @example Get the slaves.
    #   config.slaves
    #
    # @return [ Array<Mongo::DB>, nil ] The slave databases.
    def slaves
      @slaves
    end

    # Sets whether the times returned from the database are in UTC or local time.
    # If you omit this setting, then times will be returned in
    # the local time zone.
    #
    # @example Set the use of UTC.
    #   config.use_utc = true
    #
    # @param [ true, false ] value Whether to use UTC or not.
    #
    # @return [ true, false ] Are we using UTC?
    def use_utc=(value)
      @use_utc = value || false
    end

    # Returns whether times are return from the database in UTC. If
    # this setting is false, then times will be returned in the local time zone.
    #
    # @example Are we using UTC?
    #   config.use_utc
    #
    # @return [ true, false ] True if UTC, false if not.
    attr_reader :use_utc
    alias :use_utc? :use_utc

    protected

    # Check if the database is valid and the correct version.
    #
    # @example Check if the database is valid.
    #   config.check_database!
    #
    # @param [ Mongo::DB ] database The db to check.
    #
    # @raise [ Errors::InvalidDatabase ] If the object is not valid.
    # @raise [ Errors::UnsupportedVersion ] If the db version is too old.
    def check_database!(database)
      raise Errors::InvalidDatabase.new(database) unless database.kind_of?(Mongo::DB)
      unless skip_version_check
        version = database.connection.server_version
        raise Errors::UnsupportedVersion.new(version) if version < Mongoid::MONGODB_VERSION
      end
    end

    # Get a master database from settings.
    #
    # @example Configure the master db.
    #   config._master({}, "test")
    #
    # @param [ Hash ] settings The settings to use.
    def _master(settings)
      mongo_uri = settings["uri"].present? ? URI.parse(settings["uri"]) : OpenStruct.new

      name = settings["database"] || mongo_uri.path.to_s.sub("/", "")
      host = settings["host"] || mongo_uri.host || "localhost"
      port = settings["port"] || mongo_uri.port || 27017
      pool_size = settings["pool_size"] || 1
      username = settings["username"] || mongo_uri.user
      password = settings["password"] || mongo_uri.password

      connection = Mongo::Connection.new(host, port, :logger => Mongoid::Logger.new, :pool_size => pool_size)
      if username || password
        connection.add_auth(name, username, password)
        connection.apply_saved_authentication
      end
      self.master = connection.db(name)
    end

    # Get a bunch-o-slaves from settings and names.
    #
    # @example Configure the slaves.
    #   config._slaves({}, "test")
    #
    # @param [ Hash ] settings The settings to use.
    def _slaves(settings)
      mongo_uri = settings["uri"].present? ? URI.parse(settings["uri"]) : OpenStruct.new
      name = settings["database"] || mongo_uri.path.to_s.sub("/", "")
      self.slaves = []
      slaves = settings["slaves"]
      slaves.to_a.each do |slave|
        slave_uri = slave["uri"].present? ? URI.parse(slave["uri"]) : OpenStruct.new
        slave_username = slave["username"] || slave_uri.user
        slave_password = slave["password"] || slave_uri.password

        slave_connection = Mongo::Connection.new(
          slave["host"] || slave_uri.host || "localhost",
          slave["port"] || slave_uri.port,
          :slave_ok => true
        )

        if slave_username || slave_password
          slave_connection.add_auth(name, slave_username, slave_password)
          slave_connection.apply_saved_authentication
        end
        self.slaves << slave_connection.db(name)
      end
    end
  end
end
