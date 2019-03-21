module KenticoCloud
  module Delivery
    class TaxonomyGroup
      # Parses the 'terms' JSON node as a dynamic OpenStruct object.
      #
      # * *Returns*:
      #   - +OpenStruct+ The terms of the taxonomy group as a dynamic object
      def terms
        @terms unless @terms.nil?
        @terms = JSON.parse(
          JSON.generate(@source['terms']),
          object_class: OpenStruct
        )
      end

      # Parses the 'system' JSON node as a dynamic OpenStruct object.
      #
      # * *Returns*:
      #   - +OpenStruct+ The system properties of the taxonomy group
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
      #   - *json* (+JSON+) A JSON node representing a taxonomy group
      def initialize(source)
        @source = source
      end
    end
  end
end
