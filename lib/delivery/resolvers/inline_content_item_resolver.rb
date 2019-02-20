require 'nokogiri'

module Delivery
  module Resolvers
    # Locates <object data-type="item"> tags in content and calls a user-defined method
    # to supply the HTML output for the content item
    class InlineContentItemResolver
      def initialize(callback = nil)
        @callback = callback
      end

      # Resolves all inline content items in the content
      # @param [String] content The string value stored in the element
      # @param [Array] inline_items ContentItems referenced by the content
      def resolve(content, inline_items)
        doc = Nokogiri::HTML.parse(content).xpath('//body')
        tags = doc.xpath('//object[@type="application/kenticocloud"][@data-type="item"]')
        tags.each do |tag|
          output = resolve_tag tag, inline_items
          el = doc.at_xpath(
            '//object[@type="application/kenticocloud"][@data-type="item"][@data-codename=$value]',
            nil,
            value: tag['data-codename']
          )
          el.swap(output) unless output.nil?
        end
        doc.inner_html
      end

      private

      # Accepts a tag found in the content and tries to locate matching
      # ContentItem from JSON response.
      def resolve_tag(tag, inline_items)
        matches = inline_items.select { |item| item.system.codename == tag['data-codename'].to_s }
        provide_output matches
      end

      def provide_output(matches)
        if !matches.empty?
          if @callback.nil?
            resolve_item matches[0]
          else
            @callback.call matches[0]
          end
        end
      end
    end
  end
end
