require 'nokogiri'

module Delivery
  module Resolvers
    # Locates <a data-item-id=""> tags in content and calls a user-defined method
    # to supply the href for content item links
    class ContentLinkResolver
      def initialize(callback = nil)
        @callback = callback
      end

      # Resolves all links in the content
      # @param [String] content The string value stored in the element
      # @param [Array] links The collection of source links from the JSON response
      def resolve(content, links)
        doc = Nokogiri::HTML.parse(content).xpath('//body')
        links = links.map { |link| ContentLink.new link }
        tags = doc.xpath('//a[@data-item-id]')
        # This line performs the link resolving and replaces the tags in doc
        tags.map { |tag| resolve_tag tag, links }
        doc.inner_html
      end

      private

      # Accepts a tag found in the content and tries to locate matching
      # source link from JSON response. If found, resolves URL and returns
      # the tag with generated HREF
      def resolve_tag(tag, links)
        matches = links.select { |link| link.id == tag['data-item-id'].to_s }
        url = provide_url matches
        tag['href'] = url
        tag
      end

      # Returns a url if a link was found in source links, otherwise returns 404
      def provide_url(matches)
        if !matches.empty?
          if @callback.nil?
            resolve_link matches[0]
          else
            @callback.call matches[0]
          end
        else
          '/404'
        end
      end
    end

    # Model for links from the JSON response
    class ContentLink
      attr_accessor :code_name, :type, :url_slug, :id

      def initialize(link)
        self.id = link[0]
        self.code_name = link[1]['codename']
        self.type = link[1]['type']
        self.url_slug = link[1]['url_slug']
      end
    end
  end
end
