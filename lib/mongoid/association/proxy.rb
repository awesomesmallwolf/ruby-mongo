# encoding: utf-8
require "mongoid/association/marshalable"

module Mongoid
  module Association

    # This class is the superclass for all relation proxy objects, and contains
    # common behaviour for all of them.
    class Proxy
      alias :extend_proxy :extend

      # We undefine most methods to get them sent through to the target.
      instance_methods.each do |method|
        undef_method(method) unless
          method =~ /^(__.*|send|object_id|equal\?|respond_to\?|tap|public_send|extend_proxy|extend_proxies)$/
      end

      include Threaded::Lifecycle
      include Marshalable

      attr_accessor :base, :__association, :target

      # Backwards compatibility with Mongoid beta releases.
      delegate :foreign_key, :inverse_foreign_key, to: :__association
      delegate :bind_one, :unbind_one, to: :binding
      delegate :collection_name, to: :base

      # Convenience for setting the target and the association metadata properties since
      # all proxies will need to do this.
      #
      # @example Initialize the proxy.
      #   proxy.init(person, name, association)
      #
      # @param [ Document ] base The base document on the proxy.
      # @param [ Document, Array<Document> ] target The target of the proxy.
      # @param [ Association ] association The association metadata.
      #
      # @since 2.0.0.rc.1
      def init(base, target, association)
        @base, @target, @__association = base, target, association
        yield(self) if block_given?
        extend_proxies(association.extension) if association.extension
      end

      # Allow extension to be an array and extend each module
      def extend_proxies(*extension)
        extension.flatten.each {|ext| extend_proxy(ext) }
      end

      # Get the class from the association, or return nil if no association present.
      #
      # @example Get the class.
      #   proxy.klass
      #
      # @return [ Class ] The relation class.
      #
      # @since 3.0.15
      def klass
        __association ? __association.klass : nil
      end

      # Resets the criteria inside the relation proxy. Used by many to many
      # relations to keep the underlying ids array in sync.
      #
      # @example Reset the relation criteria.
      #   person.preferences.reset_relation_criteria
      #
      # @since 3.0.14
      def reset_unloaded
        target.reset_unloaded(criteria)
      end

      # The default substitutable object for a relation proxy is the clone of
      # the target.
      #
      # @example Get the substitutable.
      #   proxy.substitutable
      #
      # @return [ Object ] A clone of the target.
      #
      # @since 2.1.6
      def substitutable
        target
      end

      protected

      # Get the collection from the root of the hierarchy.
      #
      # @example Get the collection.
      #   relation.collection
      #
      # @return [ Collection ] The root's collection.
      #
      # @since 2.0.0
      def collection
        root = base._root
        root.collection unless root.embedded?
      end

      # Takes the supplied document and sets the association on it.
      #
      # @example Set the association metadata.
      #   proxt.characterize_one(name)
      #
      # @param [ Document ] document The document to set on.
      #
      # @since 2.0.0.rc.4
      def characterize_one(document)
        document.__association = __association unless document.__association
      end

      # Default behavior of method missing should be to delegate all calls
      # to the target of the proxy. This can be overridden in special cases.
      #
      # @param [ String, Symbol ] name The name of the method.
      # @param [ Array ] args The arguments passed to the method.
      #
      def method_missing(name, *args, &block)
        target.send(name, *args, &block)
      end

      # When the base document illegally references an embedded document this
      # error will get raised.
      #
      # @example Raise the error.
      #   relation.raise_mixed
      #
      # @raise [ Errors::MixedRelations ] The error.
      #
      # @since 2.0.0
      def raise_mixed
        raise Errors::MixedRelations.new(base.class, __association.klass)
      end

      # When the base is not yet saved and the user calls create or create!
      # on the relation, this error will get raised.
      #
      # @example Raise the error.
      #   relation.raise_unsaved(post)
      #
      # @param [ Document ] doc The child document getting created.
      #
      # @raise [ Errors::UnsavedDocument ] The error.
      #
      # @since 2.0.0.rc.6
      def raise_unsaved(doc)
        raise Errors::UnsavedDocument.new(base, doc)
      end

      # Executes a callback method
      #
      # @example execute the before add callback
      #   execute_callback(:before_add)
      #
      # @param [ Symbol ] callback to be executed
      #
      # @since 3.1.0
      def execute_callback(callback, doc)
        __association.get_callbacks(callback).each do |c|
          if c.is_a? Proc
            c.call(base, doc)
          else
            base.send c, doc
          end
        end
      end

      class << self

        # Apply ordering to the criteria if it was defined on the relation.
        #
        # @example Apply the ordering.
        #   Proxy.apply_ordering(criteria, association)
        #
        # @param [ Criteria ] criteria The criteria to modify.
        # @param [ Association ] association The association metadata.
        #
        # @return [ Criteria ] The ordered criteria.
        #
        # @since 3.0.6
        def apply_ordering(criteria, association)
          association.order ? criteria.order_by(association.order) : criteria
        end
      end
    end
  end
end
