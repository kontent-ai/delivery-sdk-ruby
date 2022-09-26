require 'ostruct'

module Kontent
  module Ai
    module Delivery
      class Language
        # Parses the 'system' JSON object as a dynamic OpenStruct object.
        #
        # * *Returns*:
        #   - +OpenStruct+ The system properties of the language
        def system
          @system unless @system.nil?
          @system = JSON.parse(
            JSON.generate(@source['system']),
            object_class: OpenStruct
          )
        end

        # Constructor.
        #
        # * *Args*:
        #   - *source* (+JSON+) The response from a REST request for a language
        def initialize(source)
          @source = source
        end
      end
    end
  end
end
