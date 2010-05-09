# encoding: utf-8
module Mongoid #:nodoc:
  module Validations #:nodoc:
    # Validates whether or not a field is unique against the documents in the
    # database.
    #
    # Example:
    #
    #   class Person
    #     include Mongoid::Document
    #     field :title
    #
    #     validates_uniqueness_of :title
    #   end
    class UniquenessValidator < ActiveModel::EachValidator
      def validate_each(document, attribute, value)
        conditions = {attribute => value}
        conditions[options[:scope]] = document.attributes[options[:scope]] if options.has_key? :scope
        return if document.class.where(conditions).empty?
        if document.new_record? || key_changed?(document)
          document.errors.add(attribute, :taken, :default => options[:message], :value => value)
        end
      end

      protected
      def key_changed?(document)
        (document.primary_key || {}).each do |key|
          return true if document.send("#{key}_changed?")
        end; false
      end
    end
  end
end
