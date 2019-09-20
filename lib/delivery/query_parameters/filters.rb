require 'delivery/query_parameters/parameter_base'

module Kentico
  module Kontent
    module Delivery
      module QueryParameters
        # Provides the base class for filter implementations.
        # See https://developer.kenticocloud.com/v1/reference#content-filtering
        class Filter < ParameterBase
          # Constructor.
          #
          # * *Args*:
          #   - *key* (+string+) The field to filter upon
          #   - *operator* (+string+) The Kentico Cloud filter being applied to the field, in brackets
          #   - *values* (+Object+) One or more values which will appear as the value of the query string parameter
          def initialize(key, operator, values)
            super(key, operator, values)
          end
        end
      end
    end
  end
end

# Extend String class to allow semantic typing of filters
class String
  # Represents a filter that matches a content item if the specified content
  # element or system attribute has a value that contains all the specified
  # values. This filter is applicable to array values only, such as sitemap
  # location or value of Linked Items, Taxonomy and Multiple choice content elements.
  #
  # * *Args*:
  #   - +Object+ One or more objects representing the values that must appear in the field
  #
  # * *Returns*:
  #   - Kentico::Kontent::Delivery::QueryParameters::Filter
  def all(*args)
    Kentico::Kontent::Delivery::QueryParameters::Filter.new(self, '[all]', *args)
  end

  # Represents a filter that matches a content item if the specified content
  # element or system attribute has a value that contains any the specified
  # values. This filter is applicable to array values only, such as sitemap
  # location or value of Linked Items, Taxonomy and Multiple choice content elements.
  #
  # * *Args*:
  #   - +Object+ One or more objects representing the values that may appear in the field
  #
  # * *Returns*:
  #   - Kentico::Kontent::Delivery::QueryParameters::Filter
  def any(*args)
    Kentico::Kontent::Delivery::QueryParameters::Filter.new(self, '[any]', *args)
  end

  # Represents a filter that matches a content item if the specified content element
  # or system attribute has a value that contains the specified value.
  # This filter is applicable to array values only, such as sitemap location or value
  # of Linked Items, Taxonomy and Multiple choice content elements.
  #
  # * *Args*:
  #   - +Object+ An object representing the value that must appear in the field
  #
  # * *Returns*:
  #   - Kentico::Kontent::Delivery::QueryParameters::Filter
  def contains(*args)
    Kentico::Kontent::Delivery::QueryParameters::Filter.new(self, '[contains]', *args)
  end

  # Represents a filter that matches a content item if the specified
  # content element or system attribute has the specified value.
  #
  # * *Args*:
  #   - +Object+ An object representing the value that must equal the value in the field
  #
  # * *Returns*:
  #   - Kentico::Kontent::Delivery::QueryParameters::Filter
  def eq(*args)
    Kentico::Kontent::Delivery::QueryParameters::Filter.new(self, '', *args)
  end

  # Represents a filter that matches a content item if the specified content
  # element or system attribute has a value that is greater than the
  # specified value.
  #
  # * *Args*:
  #   - +Object+ An object representing the lowest possible value of the field, non-inclusive
  #
  # * *Returns*:
  #   - Kentico::Kontent::Delivery::QueryParameters::Filter
  def gt(*args)
    Kentico::Kontent::Delivery::QueryParameters::Filter.new(self, '[gt]', *args)
  end

  # Represents a filter that matches a content item if the specified content
  # element or system attribute has a value that is greater than or equal to
  # the specified value.
  #
  # * *Args*:
  #   - +Object+ An object representing the lowest possible value of the field
  #
  # * *Returns*:
  #   - Kentico::Kontent::Delivery::QueryParameters::Filter
  def gt_or_eq(*args)
    Kentico::Kontent::Delivery::QueryParameters::Filter.new(self, '[gte]', *args)
  end

  # Represents a filter that matches a content item if the specified
  # content element or system attribute has a value that matches a
  # value in the specified list.
  #
  # * *Args*:
  #   - +Object+ One or more objects representing the required values of the field
  #
  # * *Returns*:
  #   - Kentico::Kontent::Delivery::QueryParameters::Filter
  def in(*args)
    Kentico::Kontent::Delivery::QueryParameters::Filter.new(self, '[in]', *args)
  end

  # Represents a filter that matches a content item if the specified content
  # element or system attribute has a value that is less than the
  # specified value.
  #
  # * *Args*:
  #   - +Object+ An object representing the highest possible value of the field, non-inclusive
  #
  # * *Returns*:
  #   - Kentico::Kontent::Delivery::QueryParameters::Filter
  def lt(*args)
    Kentico::Kontent::Delivery::QueryParameters::Filter.new(self, '[lt]', *args)
  end

  # Represents a filter that matches a content item if the specified content
  # element or system attribute has a value that is less than or equal to
  # the specified value.
  #
  # * *Args*:
  #   - +Object+ An object representing the highest possible value of the field
  #
  # * *Returns*:
  #   - Kentico::Kontent::Delivery::QueryParameters::Filter
  def lt_or_eq(*args)
    Kentico::Kontent::Delivery::QueryParameters::Filter.new(self, '[lte]', *args)
  end

  # Represents a filter that matches a content item if the specified
  # content element or system attribute has a value that falls within
  # the specified range of values (both inclusive).
  #
  # * *Args*:
  #   - +Object+ An object representing the lowest and highest possible values of the field
  #
  # * *Returns*:
  #   - Kentico::Kontent::Delivery::QueryParameters::Filter
  def range(*args)
    Kentico::Kontent::Delivery::QueryParameters::Filter.new(self, '[range]', *args)
  end
end
