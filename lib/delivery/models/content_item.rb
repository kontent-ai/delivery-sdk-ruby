require 'ostruct'

module Delivery
  # JSON data of a content item parsed as OpenStruct objects for dynamic use
  class ContentItem
    attr_accessor :content_link_url_resolver

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

    def initialize(source, content_link_url_resolver)
      @source = source
      self.content_link_url_resolver = content_link_url_resolver
    end

    def get_string(code_name)
      element = get_element code_name

      # Resolve content links if there are any and we have a resolver
      return content_link_url_resolver.resolve element['value'], element['links'] if should_resolve element

      element['value'].to_s
    end

    def should_resolve(element)
      element['type'] == 'rich_text' && !element['links'].nil? && !content_link_url_resolver.nil?
    end

    def get_element(code_name)
      raise ArgumentError, "Argument 'code_name' cannot be null" if code_name.nil?
      raise ArgumentError, "Argument 'code_name' is not a string" unless code_name.is_a? String

      @source['elements'][code_name]
    end
  end
end
