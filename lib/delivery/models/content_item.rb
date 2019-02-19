require 'ostruct'
require 'nokogiri'

module Delivery
  # JSON data of a content item parsed as OpenStruct objects for dynamic use
  class ContentItem
    attr_accessor :content_link_url_resolver,
                  :inline_content_item_resolver

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

    def initialize(source, content_link_url_resolver, inline_content_item_resolver, modular_content = nil)
      @source =
        if source['item'].nil?
          source
        else
          source['item']
        end
      # Multiple item responses have modular_content on the root, single item
      # responses have modular content in the item
      @modular_content =
        if modular_content.nil?
          source['modular_content']
        else
          modular_content
        end
      self.content_link_url_resolver = content_link_url_resolver
      self.inline_content_item_resolver = inline_content_item_resolver
    end

    def get_string(code_name)
      element = get_element code_name
      content = element['value']

      if element['type'] == 'rich_text'
        content = content_link_url_resolver.resolve content, element['links'] if should_resolve_links element
        inline_items = get_inline_items code_name
        content = inline_content_item_resolver.resolve content, inline_items if should_resolve_inline_content element
      end
      content.to_s
    end

    # Returns an array of assets inserted into the specified element
    def get_assets(code_name)
      element = get_element code_name
      element['value'].map { |n| OpenStruct.new(n) }
    end

    # Returns an array of ContentItems by comparing code names stored in the
    # element with items from request's modular_content
    def get_links(code_name)
      element = get_element code_name
      filtered = filter_modular_content element['value']
      filtered.map { |n| ContentItem.new JSON.parse(JSON.generate(n)), content_link_url_resolver, inline_content_item_resolver }
    end

    # Returns an array of ContentItems by comparing code names stored in the
    # modular_content object with items from request's modular_content
    def get_inline_items(code_name)
      element = get_element code_name
      filtered = filter_modular_content element['modular_content']
      filtered.map { |n| ContentItem.new JSON.parse(JSON.generate(n)), content_link_url_resolver, inline_content_item_resolver }
    end

    private

    def should_resolve_links(element)
      !element['links'].nil? && !content_link_url_resolver.nil?
    end

    def should_resolve_inline_content(element)
      !element['modular_content'].nil? && !inline_content_item_resolver.nil?
    end

    def get_element(code_name)
      raise ArgumentError, "Argument 'code_name' cannot be null" if code_name.nil?
      raise ArgumentError, "Argument 'code_name' is not a string" unless code_name.is_a? String

      @source['elements'][code_name]
    end

    def filter_modular_content(codenames)
      return [] unless codenames.class == Array

      codenames.each_with_object([]) do |codename, items|
        item = @modular_content.values.find { |i| i['system']['codename'] == codename }
        items << item if item
      end
    end
  end
end
