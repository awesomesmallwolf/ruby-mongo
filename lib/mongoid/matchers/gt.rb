# encoding: utf-8
module Mongoid #:nodoc:
  module Matchers #:nodoc:
    class Gt < Default
      # Return true if the attribute is greater than the value.
      def matches?(value)
        @attribute ? @attribute > value.values.first : false
      end
    end
  end
end
