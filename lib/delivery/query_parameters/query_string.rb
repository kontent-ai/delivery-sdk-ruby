require 'delivery/query_parameters/parameter_base'

module Delivery
  module QueryParameters
    class QueryString
      def initialize
        @params = []
      end

      # Adds a parameter to the query string
      # @param [String] param Either a string representing the key for the parameter, or a complete ParameterBase object
      # @param [String] values A string or array of strings representing the values for the parameter
      # @param [String] operator Kentico Cloud filtering parameter, placed after the key, before the equal sign
      def set_param(param, values = '', operator = '')
        parameter_base =
          if param.is_a? String
            Delivery::QueryParameters::ParameterBase.new(
              param,
              operator,
              values
            )
          else
            param
          end
        # Ensure we have a ParameterBase object
        return unless parameter_base.respond_to? 'provide_query_string_parameter'

        remove_param parameter_base.key
        @params << parameter_base
      end

      def remove_param(key)
        @params.delete_if { |i| i.key.eql? key }
      end

      def param(key)
        @params.select { |p| p.key.eql? key }
      end

      def empty?
        @params.empty?
      end

      def to_s
        '?' + @params.map(&:provide_query_string_parameter).join('&')
      end
    end
  end
end
