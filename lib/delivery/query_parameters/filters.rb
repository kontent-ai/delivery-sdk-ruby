module Delivery
  module Filters

    # Provides the base class for filter implementations.
    class Filter
      SEPARATOR = CGI.escape(',')

      def initialize(element_or_attribute, values, operator = '')
        @e_or_a = element_or_attribute
        @operator = operator
        values = [values] unless values.respond_to? :each
        @values = values
      end

      def provide_query_string_parameter
        escaped_values = []
        @values.each { |n| escaped_values << CGI.escape(n.to_s) }
        format(
          '%<e>s%<o>s=%<v>s',
          e: CGI.escape(@e_or_a),
          o: CGI.escape(@operator),
          v: escaped_values.join(SEPARATOR)
        )
      end
    end

    # Represents a filter that matches a content item if the specified content
    # element or system attribute has a value that contains all the specified
    # values. This filter is applicable to array values only, such as sitemap
    # location or value of Linked Items, Taxonomy and Multiple choice content elements.
    class AllFilter < Filter
      def initialize(*args)
        super(*args, '[all]')
      end
    end

    # Represents a filter that matches a content item if the specified content
    # element or system attribute has a value that contains any the specified
    # values. This filter is applicable to array values only, such as sitemap
    # location or value of Linked Items, Taxonomy and Multiple choice content elements.
    class AnyFilter < Filter
      def initialize(*args)
        super(*args, '[any]')
      end
    end

    # Represents a filter that matches a content item if the specified content element
    # or system attribute has a value that contains the specified value.
    # This filter is applicable to array values only, such as sitemap location or value
    # of Linked Items, Taxonomy and Multiple choice content elements.
    class ContainsFilter < Filter
      def initialize(*args)
        super(*args, '[contains]')
      end
    end

    # Represents a filter that matches a content item if the specified
    # content element or system attribute has the specified value.
    class EqualsFilter < Filter
      def initialize(*args)
        super(*args)
      end
    end

    # Represents a filter that matches a content item if the specified content
    # element or system attribute has a value that is greater than the
    # specified value.
    class GreaterThanFilter < Filter
      def initialize(*args)
        super(*args, '[gt]')
      end
    end

    # Represents a filter that matches a content item if the specified content
    # element or system attribute has a value that is greater than or equal to
    # the specified value.
    class GreaterThanOrEqualToFilter < Filter
      def initialize(*args)
        super(*args, '[gte]')
      end
    end

    # Represents a filter that matches a content item if the specified
    # content element or system attribute has a value that matches a
    # value in the specified list.
    class InFilter < Filter
      def initialize(*args)
        super(*args, '[in]')
      end
    end

    # Represents a filter that matches a content item if the specified content
    # element or system attribute has a value that is less than the
    # specified value.
    class LessThanFilter < Filter
      def initialize(*args)
        super(*args, '[lt]')
      end
    end

    # Represents a filter that matches a content item if the specified content
    # element or system attribute has a value that is less than or equal to
    # the specified value.
    class LessThanOrEqualToFilter < Filter
      def initialize(*args)
        super(*args, '[lte]')
      end
    end

    # Represents a filter that matches a content item if the specified
    # content element or system attribute has a value that falls within
    # the specified range of values (both inclusive).
    class RangeFilter < Filter
      def initialize(*args)
        super(*args, '[range]')
      end
    end
  end
end
