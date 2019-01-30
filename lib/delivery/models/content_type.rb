require 'ostruct'

module Delivery
  # JSON data of a content type parsed as OpenStruct objects for dynamic use
  class ContentType
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
  end
end
