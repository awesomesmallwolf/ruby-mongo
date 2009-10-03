module Mongoid #:nodoc:
  module Associations #:nodoc:
    class BelongsToAssociation #:nodoc:
      include Decorator

      # Creates the new association by setting the internal 
      # document as the passed in Document. This should be the
      # parent.
      #
      # All method calls on this object will then be delegated
      # to the internal document itself.
      def initialize(document)
        @document = document.parent
        decorate!
      end
    end
  end
end
