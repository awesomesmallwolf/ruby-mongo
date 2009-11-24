module Mongoid #:nodoc:
  module Associations #:nodoc:
    class HasOne #:nodoc:
      include Decorator

      delegate :valid?, :to => :document

      attr_accessor :klass, :parent, :association_name

      # Build a new object for the association.
      def build(attributes)
        @document = @klass.instantiate(attributes)
        @document.parentize(@parent, @association_name)
        @document.notify
        decorate!
        self
      end

      # Create a new object for the association and save it.
      def create(attributes)
        build(attributes)
        @document.save
        self
      end

      # Creates the new association by finding the attributes in 
      # the parent document with its name, and instantiating a 
      # new document for it.
      #
      # All method calls on this object will then be delegated
      # to the internal document itself.
      def initialize(document, options)
        @klass, @parent, @association_name = options.klass, document, options.name
        attributes = document.attributes[options.name]
        @document = klass.instantiate(attributes || {})
        @document.parentize(document, options.name)
        decorate!
      end

      class << self
        # Perform an update of the relationship of the parent and child. This
        # is initialized by setting the has_one to the supplied child.
        def update(child, parent, options)
          unless child.respond_to?(:parentize)
            klass = options.klass
            child = klass.new(child)
          end
          child.parentize(parent, options.name)
          child.notify
          child
        end
      end

    end
  end
end
