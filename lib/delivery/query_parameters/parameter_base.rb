require 'cgi'

module Kontent
  module Ai
    module Delivery
      module QueryParameters
        # Base class for all parameters added to a DeliveryQuery. All
        # QueryParameters will appear in the query string.
        class ParameterBase
          attr_accessor :key
          SEPARATOR = CGI::escape(',')

          # Constructor.
          #
          # * *Args*:
          #   - *key* (+string+) The field to filter upon
          #   - *operator* (+string+) The Kontent.ai filter being applied to the field, in brackets
          #   - *values* (+Object+) One or more values which will appear as the value of the query string parameter
          #   - *eq_sign* (+boolean+) If false, the equals sign is not generated in the parameter
          def initialize(key, operator, values, eq_sign = true)
            self.key = key
            values = [values] unless values.respond_to? :each
            @values = values
            @operator = operator
            @eq_sign = eq_sign
          end

          # Converts the object into a valid query string parameter for use in
          # a request to Delivery. The key, operator, and values are all escaped
          # and if there are multiple values, they are joined with commas.
          #
          # * *Returns*:
          #   - +string+ A query string parameter without any additional characters (e.g. '&')
          def provide_query_string_parameter
            escaped_values = []
            @values.each { |n| escaped_values << CGI.escape(n.to_s) }
            if @eq_sign 
              format(
                '%<k>s%<o>s=%<v>s',
                k: CGI.escape(key),
                o: CGI.escape(@operator),
                v: escaped_values.join(SEPARATOR)
              )
            else
              format(
                '%<k>s%<o>s',
                k: CGI.escape(key),
                o: CGI.escape(@operator)
              )
            end
          end
        end
      end
    end
  end
end
