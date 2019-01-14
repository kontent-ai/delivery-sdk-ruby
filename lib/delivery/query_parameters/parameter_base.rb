module Delivery
  # Contains static methods for adding parameters to a DeliveryQuery
  # as well as the Filter class.
  module QueryParameters
    # Base class for all parameters added to a DeliveryQuery using the
    # .parameters method. All parameters appear in the query string.
    class ParameterBase
      attr_accessor :key
      SEPARATOR = CGI.escape(',')

      def initialize(key, operator, values)
        self.key = key
        values = [values] unless values.respond_to? :each
        @values = values
        @operator = operator
      end

      def provide_query_string_parameter
        escaped_values = []
        @values.each { |n| escaped_values << CGI.escape(n.to_s) }
        format(
          '%<k>s%<o>s=%<v>s',
          k: CGI.escape(key),
          o: CGI.escape(@operator),
          v: escaped_values.join(SEPARATOR)
        )
      end
    end
  end
end
