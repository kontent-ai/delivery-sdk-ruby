require 'ostruct'

module Delivery
  # JSON data of a content item parsed as OpenStruct objects for dynamic use
  class ContentItem
    def elements
      @elements unless @elements.nil?
      @elements = JSON.parse(
        JSON.generate(@source['elements']),
        object_class: OpenStruct
      )
    end

    def system
      @system unless @system.nil?
      @system = JSON.parse(
        JSON.generate(@source['system']),
        object_class: OpenStruct
      )
    end

    def initialize(source)
      @source = source
    end

    def get_element(code_name)
      raise ArgumentError, "Argument 'code_name' cannot be null" if code_name.nil?
      raise ArgumentError, "Argument 'code_name' is not a string" unless code_name.is_a? String

      @source['elements'][code_name]
    end
  end
end
