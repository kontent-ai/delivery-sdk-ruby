require 'delivery/query_parameters/parameter_base'

module KenticoCloud
  module Delivery
    module QueryParameters
      # Provides the base class for filter implementations.
      class Filter < ParameterBase
        def initialize(key, operator, values)
          super(key, operator, values)
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
  def all(*args)
    KenticoCloud::Delivery::QueryParameters::Filter.new(self, '[all]', *args)
  end

  # Represents a filter that matches a content item if the specified content
  # element or system attribute has a value that contains any the specified
  # values. This filter is applicable to array values only, such as sitemap
  # location or value of Linked Items, Taxonomy and Multiple choice content elements.
  def any(*args)
    KenticoCloud::Delivery::QueryParameters::Filter.new(self, '[any]', *args)
  end

  # Represents a filter that matches a content item if the specified content element
  # or system attribute has a value that contains the specified value.
  # This filter is applicable to array values only, such as sitemap location or value
  # of Linked Items, Taxonomy and Multiple choice content elements.
  def contains(*args)
    KenticoCloud::Delivery::QueryParameters::Filter.new(self, '[contains]', *args)
  end

  # Represents a filter that matches a content item if the specified
  # content element or system attribute has the specified value.
  def eq(*args)
    KenticoCloud::Delivery::QueryParameters::Filter.new(self, '', *args)
  end

  # Represents a filter that matches a content item if the specified content
  # element or system attribute has a value that is greater than the
  # specified value.
  def gt(*args)
    KenticoCloud::Delivery::QueryParameters::Filter.new(self, '[gt]', *args)
  end

  # Represents a filter that matches a content item if the specified content
  # element or system attribute has a value that is greater than or equal to
  # the specified value.
  def gt_or_eq(*args)
    KenticoCloud::Delivery::QueryParameters::Filter.new(self, '[gte]', *args)
  end

  # Represents a filter that matches a content item if the specified
  # content element or system attribute has a value that matches a
  # value in the specified list.
  def in(*args)
    KenticoCloud::Delivery::QueryParameters::Filter.new(self, '[in]', *args)
  end

  # Represents a filter that matches a content item if the specified content
  # element or system attribute has a value that is less than the
  # specified value.
  def lt(*args)
    KenticoCloud::Delivery::QueryParameters::Filter.new(self, '[lt]', *args)
  end

  # Represents a filter that matches a content item if the specified content
  # element or system attribute has a value that is less than or equal to
  # the specified value.
  def lt_or_eq(*args)
    KenticoCloud::Delivery::QueryParameters::Filter.new(self, '[lte]', *args)
  end

  # Represents a filter that matches a content item if the specified
  # content element or system attribute has a value that falls within
  # the specified range of values (both inclusive).
  def range(*args)
    KenticoCloud::Delivery::QueryParameters::Filter.new(self, '[range]', *args)
  end
end
