require 'ostruct'
require 'nokogiri'

module KenticoCloud
  module Delivery
    class ContentItem
      attr_accessor :content_link_url_resolver,
                    :inline_content_item_resolver

      # Parses the 'elements' JSON object as a dynamic OpenStruct object.
      #
      # * *Returns*:
      #   - +OpenStruct+ The elements of the content item
      def elements
        @elements unless @elements.nil?
        @elements = JSON.parse(
          JSON.generate(@source['elements']),
          object_class: OpenStruct
        )
      end

      # Parses the 'system' JSON object as a dynamic OpenStruct object.
      #
      # * *Returns*:
      #   - +OpenStruct+ The system properties of the content item
      def system
        @system unless @system.nil?
        @system = JSON.parse(
          JSON.generate(@source['system']),
          object_class: OpenStruct
        )
      end

      # Constructor.
      #
      # * *Args*:
      #   - *source* (+JSON+) The response from a REST request for content items. The item may be on the root or under the 'item' node
      #   - *content_link_url_resolver* ( KenticoCloud::Delivery::Resolvers::ContentLinkResolver )
      #   - *inline_content_item_resolver* ( KenticoCloud::Delivery::Resolvers::InlineContentItemResolver )
      #   - *linked_items_resolver* ( KenticoCloud::Delivery::Resolvers::LinkedItemResolver )
      def initialize(source, content_link_url_resolver, inline_content_item_resolver, linked_items_resolver)
        @source =
          if source['item'].nil?
            source
          else
            source['item']
          end
        @linked_items_resolver = linked_items_resolver
        self.content_link_url_resolver = content_link_url_resolver
        self.inline_content_item_resolver = inline_content_item_resolver
      end

      # Gets a string representation of the data stored in the element. Using this
      # method instead of directly accessing the +elements+ collection causes
      # the content to be resolved using the resolvers passed during instantiation.
      # See https://github.com/Kentico/delivery-sdk-ruby#resolving-links
      #
      # * *Args*:
      #   - *code_name* (+string+) The code name of the desired element
      #
      # * *Returns*:
      #   - +string+ The data converted to a string, resolved if the element is a 'rich_text' element
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

      # Returns an array of assets inserted into the specified element of the
      # 'asset' type.
      #
      # * *Args*:
      #   - *code_name* (+string+) The code name of the desired element
      #
      # * *Returns*:
      #   - +Array+ The element's assets parsed as +OpenStruct+ objects
      def get_assets(code_name)
        element = get_element code_name
        element['value'].map { |n| OpenStruct.new(n) }
      end

      # Returns an array of ContentItems that are linked in a 'modular_content'
      # element.
      #
      # * *Args*:
      #   - *code_name* (+string+) The code name of the desired element
      #
      # * *Returns*:
      #   - +Array+ The element's linked items parsed as +ContentItem+ objects
      def get_links(code_name)
        element = get_element code_name
        get_linked_items element['value']
      end

      # Returns an array of ContentItems that are inserted as inline content
      # items or componenets of a 'rich_text' element.
      #
      # * *Args*:
      #   - *code_name* (+string+) The code name of the desired element
      #
      # * *Returns*:
      #   - +Array+ The element's inline content items parsed as +ContentItem+ objects
      def get_inline_items(code_name)
        element = get_element code_name
        get_linked_items element['modular_content']
      end

      private

      def should_resolve_links(element)
        !element['links'].nil? && !content_link_url_resolver.nil?
      end

      def should_resolve_inline_content(element)
        !element['modular_content'].nil? && !inline_content_item_resolver.nil?
      end

      # Gets the JSON object from the 'elements' collection with the specified key
      #
      # * *Args*:
      #   - *code_name* (+string+) The code name of the desired element
      #
      # * *Returns*:
      #   - +JSON+ The element as a JSON object
      #
      # * *Raises*:
      #   - +ArgumentError+ if +code_name+ is +nil+ or not a +string+
      def get_element(code_name)
        raise ArgumentError, "Argument 'code_name' cannot be null" if code_name.nil?
        raise ArgumentError, "Argument 'code_name' is not a string" unless code_name.is_a? String

        @source['elements'][code_name]
      end

      def get_linked_items(codenames)
        return [] unless codenames.class == Array

        codenames.each_with_object([]) do |codename, items|
          item = @linked_items_resolver.resolve codename
          items << item if item
        end
      end
    end
  end
end
