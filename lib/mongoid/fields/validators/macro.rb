# encoding: utf-8
module Mongoid
  module Fields
    module Validators

      # Validates the params passed to the field macro.
      module Macro
        extend self

        OPTIONS = [
          :as,
          :default,
          :identity,
          :label,
          :localize,
          :metadata,
          :pre_processed,
          :subtype,
          :type,
          :overwrite
        ]

        # Validate the field definition.
        #
        # @example Validate the field definition.
        #   Macro.validate(Model, :name, { localized: true })
        #
        # @param [ Class ] klass The model class.
        # @param [ Symbol ] name The field name.
        # @param [ Hash ] options The provided options.
        #
        # @since 3.0.0
        def validate(klass, name, options)
          validate_name(klass, name, options)
          validate_options(klass, name, options)
        end

        private

        # Determine if the field name is allowed, if not raise an error.
        #
        # @api private
        #
        # @example Check the field name.
        #   Macro.validate_name(Model, :name)
        #
        # @param [ Class ] klass The model class.
        # @param [ Symbol ] name The field name.
        #
        # @raise [ Errors::InvalidField ] If the name is not allowed.
        #
        # @since 3.0.0
        def validate_name(klass, name, options)
          if Mongoid.destructive_fields.include?(name)
            raise Errors::InvalidField.new(klass, name)
          end

          # if field alredy defined
          if !options[:overwrite] && klass.fields.keys.include?(name.to_s)
            if Mongoid.duplicate_fields_exception
              raise Errors::InvalidField.new(klass, name)
            else
              Mongoid.logger.warn("Overwriting existing field #{name}.") if Mongoid.logger
            end
          end
        end

        # Validate that the field options are allowed.
        #
        # @api private
        #
        # @example Validate the field options.
        #   Macro.validate_options(Model, :name, { localized: true })
        #
        # @param [ Class ] klass The model class.
        # @param [ Symbol ] name The field name.
        # @param [ Hash ] options The provided options.
        #
        # @raise [ Errors::InvalidFieldOption ] If an option is invalid.
        #
        # @since 3.0.0
        def validate_options(klass, name, options)
          options.keys.each do |option|
            if !OPTIONS.include?(option) && !Fields.options.include?(option)
              raise Errors::InvalidFieldOption.new(klass, name, option, OPTIONS)
            end
          end
        end
      end
    end
  end
end
