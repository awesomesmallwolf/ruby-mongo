# encoding: utf-8
module Mongoid #:nodoc:
  module Fields #:nodoc:
    module Custom #:nodoc:
      # Defines the behaviour for time with zone fields.
      class TimeWithZone
        include Definable
        include Timekeeping
      end
    end
  end
end
