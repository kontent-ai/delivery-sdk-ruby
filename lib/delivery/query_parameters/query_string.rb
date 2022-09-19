require 'delivery/query_parameters/parameter_base'

module Kontent
  module Ai
    module Delivery
      module QueryParameters
        # Represents the entire query string for a request to Delivery.
        class QueryString
          def initialize
            @params = []
          end

          # Adds a parameter to the query string
          #
          # * *Args*:
          #   - *param* (+Object+) Either a string representing the key for the parameter, or a complete Kontent::Ai::Delivery::QueryParameters::ParameterBase object
          #   - *values* (+string+) A string or array of strings representing the values for the parameter
          #   - *operator* (+string+) Kontent.ai filtering parameter, placed after the key, before the equal sign
          def set_param(param, values = '', operator = '')
            parameter_base =
              if param.is_a? String
                Kontent::Ai::Delivery::QueryParameters::ParameterBase.new(
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

          # Removes all parameters from the query string with a matching key.
          #
          # * *Args*:
          #   - *key* (+string+) Parameter key
          def remove_param(key)
            @params.delete_if { |i| i.key.eql? key }
          end

          # Returns all parameters from the query string with a matching key.
          #
          # * *Args*:
          #   - *key* (+string+) Parameter key
          #
          # * *Returns*:
          #   - +Object+ One or more Kontent::Ai::Delivery::QueryParameters::ParameterBase objects
          def param(key)
            @params.select { |p| p.key.eql? key }
          end

          # Checks whether there are any parameters defined.
          #
          # * *Returns*:
          #   - +bool+ True if there are no parameters set.
          def empty?
            @params.empty?
          end

          # Generates a full query string based on the set parameters, with the
          # required '?' character at the start. Accomplished by calling the
          # Kontent::Ai::Delivery::QueryParameters::ParameterBase.provide_query_string_parameter
          # method for each parameter.
          #
          # * *Returns*:
          #   - +string+ A complete query string
          def to_s
            '?' + @params.map(&:provide_query_string_parameter).join('&')
          end
        end
      end
    end
  end
end
