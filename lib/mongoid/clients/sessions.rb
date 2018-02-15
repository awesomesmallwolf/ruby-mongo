module Mongoid
  module Clients

    # Encapsulates behavior for getting a session from the client of a model class or instance,
    # setting the session on the current thread, and yielding to a block.
    # The session will be closed after the block completes or raises an error.
    #
    # @since 6.4.0
    module Sessions

      NOT_SUPPORTED = 'not supported'

      # Execute a block within the context of a session.
      #
      # @example Execute some operations in the context of a session.
      #   band.with_session(causal_consistency: true) do
      #     band.records << Record.create
      #     band.name = 'FKA Twigs'
      #     band.save
      #     band.reload
      #   end
      #
      # @param [ Hash ] options The session options. Please see the driver
      #   documentation for the available session options.
      #
      # @note You cannot do any operations in the block using models or objects
      #   that use a different client; the block will execute all operations
      #   in the context of the implicit session and operations on any models using
      #   another client will fail. For example, if you set a client using store_in on a
      #   particular model and execute an operation on it in the session context block,
      #   that operation won't use the block's session.
      #   An error will also be raised if sessions are nested.
      #
      # @raise [ Errors::InvalidSessionUse ] If an operation is attempted on a model using another
      #   client from which the session was started or if sessions are nested.
      #
      # @return [ Object ] The result of calling the block.
      #
      # @since 6.4.0
      def with_session(options = {})
        raise Mongoid::Errors::InvalidSessionUse.new(:invalid_session_nesting) if Threaded.get_session
        session = persistence_context.client.start_session(options)
        Threaded.set_session(session)
        yield
      rescue Mongo::Error::InvalidSession => ex
        if ex.message == Mongo::Session::SESSIONS_NOT_SUPPORTED
          raise Mongoid::Errors::InvalidSessionUse.new(:sessions_not_supported)
        end
        raise Mongoid::Errors::InvalidSessionUse.new(:invalid_session_use)
      ensure
        Threaded.clear_session
      end

      private

      module ClassMethods

        # Execute a block within the context of a session.
        #
        # @example Execute some operations in the context of a session.
        #   Band.with_session(causal_consistency: true) do
        #     band = Band.create
        #     band.records << Record.new
        #     band.save
        #     band.reload.records
        #   end
        #
        # @param [ Hash ] options The session options. Please see the driver
        #   documentation for the available session options.
        #
        # @note You cannot do any operations in the block using models or objects
        #   that use a different client; the block will execute all operations
        #   in the context of the implicit session and operations on any models using
        #   another client will fail. For example, if you set a client using store_in on a
        #   particular model and execute an operation on it in the session context block,
        #   that operation won't use the block's session.
        #   You also cannot nest sessions.
        #
        # @raise [ Errors::InvalidSessionUse ] If an operation is attempted on a model using another
        #   client from which the session was started or if sessions are nested.
        #
        # @return [ Object ] The result of calling the block.
        #
        # @since 6.4.0
        def with_session(options = {})
          raise Mongoid::Errors::InvalidSessionUse.new(:invalid_session_nesting) if Threaded.get_session
          session = persistence_context.client.start_session(options)
          Threaded.set_session(session)
          yield
        rescue Mongo::Error::InvalidSession => ex
          if ex.message == Mongo::Session::SESSIONS_NOT_SUPPORTED
            raise Mongoid::Errors::InvalidSessionUse.new(:sessions_not_supported)
          end
          raise Mongoid::Errors::InvalidSessionUse.new(:invalid_session_use)
        ensure
          Threaded.clear_session
        end
      end
    end
  end
end
