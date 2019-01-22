module Delivery
  module Resolvers
    # Locates <a data-item-id=""> tags in content and calls a user-defined method
    # to supply the href for content item links 
    class ContentLinkResolver
      LINK_REGEX = /<a[^>]+?data-item-id=\"(?<id>[^\"]+)\"[^>]*>/.freeze
      NEEDLE = 'href=""'.freeze

      def initialize(callback = nil)
        @callback = callback
      end

      def resolve(content, links)
        links.map { |link| ContentLink.new link }.each do |content_link|
          url =
            if @callback.nil?
              resolve_link content_link
            else
              @callback.call content_link
            end
          url = '' if url.nil?
          content = replace(content, content_link, url)
        end
        content
      end

      # Inserts the url into the <a> tag
      def replace(content, content_link, url)
        # Find all <a data-item-id> tags in content
        matchdatas = content.to_enum(:scan, LINK_REGEX).map { Regexp.last_match }
        # Find the <a> tag that contains a matching id
        converted = matchdatas.select { |data| data['id'] == content_link.id }.map do |match|
          # Find and insert url into the href of the <a> tag
          haystack = match.to_s
          index = haystack.index NEEDLE
          return haystack if index.nil?

          haystack.insert(index + 6, url)
        end
        # Replace original text with converted text
        content.gsub(/<a[^>]+?data-item-id=\"#{content_link.id}\"[^>]*>/, converted[0])
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
