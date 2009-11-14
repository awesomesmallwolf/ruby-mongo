module Mongoid #:nodoc:
  module Associations #:nodoc:
    class HasMany < DelegateClass(Array) #:nodoc:

      attr_accessor :association_name, :klass

      # Appends the object to the +Array+, setting its parent in
      # the process.
      def <<(object)
        object.parentize(@parent, @association_name)
        @documents << object
        object.is_a?(Array) ? object.each(&:notify) : object.notify
      end

      # Clears the association, and notifies the parents of the removal.
      def clear
        object = @documents.first
        object.changed(true)
        object.notify_observers(object, true)
        super
      end

      # Appends the object to the +Array+, setting its parent in
      # the process.
      def push(object)
        self << object
      end

      # Appends the object to the +Array+, setting its parent in
      # the process.
      def concat(object)
        self << object
      end

      # Builds a new Document and adds it to the association collection. The
      # document created will be of the same class as the others in the
      # association, and the attributes will be passed into the constructor.
      #
      # Returns the newly created object.
      def build(attributes)
        object = @klass.instantiate(attributes)
        object.parentize(@parent, @association_name)
        push(object)
        object
      end

      # Finds a document in this association.
      # If :all is passed, returns all the documents
      # If an id is passed, will return the document for that id.
      def find(param)
        return @documents if param == :all
        return detect { |document| document.id == param }
      end

      # Creates the new association by finding the attributes in
      # the parent document with its name, and instantiating a
      # new document for each one found. These will then be put in an
      # internal array.
      #
      # This then delegated all methods to the array class since this is
      # essentially a proxy to an array itself.
      def initialize(name, document, options = {})
        @parent = document
        @association_name = name
        class_name = options[:class_name]
        @klass = class_name ? class_name.constantize : @association_name.to_s.classify.constantize
        attributes = document.attributes[@association_name]
        @documents = attributes ? attributes.collect do |attribute|
          child = @klass.instantiate(attribute)
          child.parentize(@parent, @association_name)
          child
        end : []
        super(@documents)
      end

      class << self
        # Perform an update of the relationship of the parent and child. This
        # is initialized by setting the has_many to the supplied +Enumerable+
        # and setting up the parentization.
        def update(children, parent, name, options = {})
          parent.attributes.delete(name)
          class_name = options[:class_name]
          klass = class_name ? class_name.constantize : name.to_s.classify.constantize
          children.each do |child|
            unless child.respond_to?(:parentize)
              child = klass.new(child)
            end
            child.parentize(parent, name)
            child.notify
          end
          new(name, parent, options)
        end
      end

    end
  end
end
