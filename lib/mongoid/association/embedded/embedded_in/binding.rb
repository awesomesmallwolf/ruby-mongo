module Mongoid
  module Association
    module Embedded
      class EmbeddedIn

        # The Binding object for embedded_in associations.
        #
        # @since 7.0
        class Binding
          include Bindable

          # Binds the base object to the inverse of the relation. This is so we
          # are referenced to the actual objects themselves on both sides.
          #
          # This case sets the association metadata on the inverse object as well as the
          # document itself.
          #
          # @example Bind the documents.
          #   name.person.bind(:continue => true)
          #   name.person = Person.new
          #
          # @option options [ true, false ] :continue Continue binding the inverse.
          # @option options [ true, false ] :binding Are we in build mode?
          #
          # @since 2.0.0.rc.1
          def bind_one
            # association metadata is defined on Binding object
            # base.__metadata is the inverse_metadata
            # If the base already has __metadata, that avoids an exception being raised
            # when the inverse_metadata is attempted to be fetched.
            _base._association = _association.inverse_association(_target) unless _base._association
            _base.parentize(_target)
            binding do
              # is determined by checking base.__metadata
              # better to use the target to check if push or a setter should be used
              # for the relation
              if _base.embedded_many?
                _target.do_or_do_not(_association.inverse(_target)).push(_base)
              else
                _target.do_or_do_not(_association.inverse_setter(_target), _base)
              end
            end
          end

          # Unbinds the base object and the inverse, caused by setting the
          # reference to nil.
          #
          # @example Unbind the document.
          #   name.person.unbind(:continue => true)
          #   name.person = nil
          #
          # @option options [ true, false ] :continue Do we continue unbinding?
          #
          # @since 2.0.0.rc.1
          def unbind_one
            binding do
              if _base.embedded_many?
                _target.do_or_do_not(_association.inverse(_target)).delete(_base)
              else
                _target.do_or_do_not(_association.inverse_setter(_target), nil)
              end
            end
          end
        end
      end
    end
  end
end
