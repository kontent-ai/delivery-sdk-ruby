require 'ostruct'

module Kentico
  module Kontent
    module Delivery
      class ContentType
        # Parses the 'elements' JSON object as a dynamic OpenStruct object.
        #
        # * *Returns*:
        #   - +OpenStruct+ The elements of the content type
        def elements
          @elements unless @elements.nil?
          @elements = JSON.parse(
            JSON.generate(@source['elements']),
            object_class: OpenStruct
          )
        end

        # Parses the 'system' JSON object as a dynamic OpenStruct object.
        #
        # * *Returns*:
        #   - +OpenStruct+ The system properties of the content type
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
        #   - *source* (+JSON+) The response from a REST request for content types
        def initialize(source)
          @source = source
        end
      end
    end
  end
end
