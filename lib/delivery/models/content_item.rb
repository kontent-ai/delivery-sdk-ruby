require 'ostruct'
require 'nokogiri'

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
      @source =
        if source['item'].nil?
          source
        else
          source['item']
        end
      @link_source = source['modular_content']
      self.content_link_url_resolver = content_link_url_resolver
    end

    def get_string(code_name)
      element = get_element code_name
      
      # Resolve content links if there are any and we have a resolver
      return content_link_url_resolver.resolve element['value'], element['links'] if should_resolve element

      element['value'].to_s
    end

    # Returns an array of assets inserted into the specified element
    def get_assets(code_name)
      element = get_element code_name
      element['value'].map { |n| OpenStruct.new(n) }
    end

    # Returns an array of ContentItems by comparing code names stored in the
    # element with items from request's link_source
    def get_links(code_name)
      element = get_element code_name
      filtered = @link_source.values.select { |item| element['value'].include?(item['system']['codename']) }
      filtered.map { |n| ContentItem.new JSON.parse(JSON.generate(n)), content_link_url_resolver }
    end

    private

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
