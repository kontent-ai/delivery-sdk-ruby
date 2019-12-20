require 'delivery/builders/url_builder'
require 'delivery/query_parameters/query_string'
require 'delivery/version'

module Kentico
  module Kontent
    module Delivery
      # Responsible for executing REST requests to Kentico Kontent.
      class DeliveryQuery
        ERROR_PREVIEW = 'Preview is enabled for the query, but the key is null. '\
                        'You can set the preview_key attribute of the query, or '\
                        'when you initialize the client. See '\
                        'https://github.com/Kentico/kontent-delivery-sdk-ruby#previewing-unpublished-content'.freeze
        ERROR_PARAMS = 'Only filters may be passed in the .item or .items methods'\
                        '. See https://github.com/Kentico/kontent-delivery-sdk-ruby#filtering'.freeze
        attr_accessor :use_preview,
                      :preview_key,
                      :project_id,
                      :code_name,
                      :secure_key,
                      :content_link_url_resolver,
                      :inline_content_item_resolver,
                      :query_type,
                      :query_string,
                      :content_type,
                      :with_retry_policy

        # Setter for a custom URL.
        #
        # * *Args*:
        #   - *url* (+string+) _optional_ Custom URL to use for the query
        #
        # * *Returns*:
        #   - +self+
        def url(url = nil)
          @url = url unless url.nil?
          self
        end

        # Constructor. Queries should not be instantiated using the constructor, but
        # using one of the Kentico::Kontent::Delivery::DeliveryClient methods instead.
        #
        # * *Args*:
        #   - *config* (+Hash+) A hash in which each key automatically has its value paired with the corresponding attribute
        def initialize(config)
          @headers = {}

          # Map each hash value to attr with corresponding key
          # from https://stackoverflow.com/a/2681014/5656214
          config.each do |k, v|
            instance_variable_set("@#{k}", v) unless v.nil?
          end
          self.query_string = Kentico::Kontent::Delivery::QueryParameters::QueryString.new
          return if config.fetch(:qp, nil).nil?

          # Query parameters were passed, parse and validate
          validate_params config.fetch(:qp)
        end

        # Executes the REST request.
        #
        # * *Returns*:
        #   - Kentico::Kontent::Delivery::Responses::ResponseBase or a class extending it
        def execute
          resp = Kentico::Kontent::Delivery::RequestManager.start self, headers
          yield resp if block_given?
          resp
        end

        # Determines whether the query should use preview mode.
        #
        # * *Returns*:
        #   - +boolean+ Whether preview mode should be used for the query
        #
        # * *Raises*:
        #   - +StandardError+ if +use_preview+ is true, but +preview_key+ is +nil+
        def should_preview
          raise ERROR_PREVIEW if use_preview && preview_key.nil?

          use_preview && !preview_key.nil?
        end

        # Enables the total_count attribute of the pagination object, which specifies
        # the total number of items returned by the query regardless of paging. See
        # https://docs.kontent.ai/reference/delivery-api#operation/list-content-items
        #
        # * *Returns*:
        #   - +self+
        def include_total_count
          query_string.set_param('includeTotalCount', 1)
          self
        end

        # Sets a content link resolver to render links contained in rich text. See
        # https://github.com/Kentico/kontent-delivery-sdk-ruby#resolving-links
        #
        # * *Args*:
        #   - *resolver* ( Kentico::Kontent::Delivery::Resolvers::ContentLinkResolver ) The resolver. Replaces a resolver registered during +DeliveryClient+ instantiation, for this query only.
        #
        # * *Returns*:
        #   - +self+
        def with_link_resolver(resolver)
          self.content_link_url_resolver = resolver
          self
        end

        # Sets an inline content itme to render content items and components in rich text.
        # See https://github.com/Kentico/kontent-delivery-sdk-ruby#resolving-inline-content
        #
        # * *Args*:
        #   - *resolver* ( Kentico::Kontent::Delivery::Resolvers::InlineContentItemResolver ) The resolver. Replaces a resolver registered during +DeliveryClient+ instantiation, for this query only.
        #
        # * *Returns*:
        #   - +self+
        def with_inline_content_item_resolver(resolver)
          self.inline_content_item_resolver = resolver
          self
        end

        # Sets the 'order' query string parameter
        #
        # * *Args*:
        #   - *value* (+string+) The value to order by
        #   - *sort* (+string+) _optional_ The direction of the order, surrounded by brackets. The default value is '[asc]'
        #
        # * *Returns*:
        #   - +self+
        def order_by(value, sort = '[asc]')
          query_string.set_param('order', value + sort)
          self
        end

        # Sets the 'skip' query string parameter for paging results.
        # See https://developer.kenticocloud.com/v1/reference#listing-response-paging
        #
        # * *Args*:
        #   - *value* (+integer+) The number to skip by
        #
        # * *Returns*:
        #   - +self+
        def skip(value)
          query_string.set_param('skip', value)
          self
        end

        # Sets the 'language' query string parameter. Language fallbacks will be used
        # if untranslated content items are found.
        # See https://developer.kenticocloud.com/docs/localization#section-getting-localized-content-items
        #
        # * *Args*:
        #   - *value* (+string+) The code name of the desired language
        #
        # * *Returns*:
        #   - +self+
        def language(value)
          query_string.set_param('language', value)
          self
        end

        # Sets the 'limit' query string parameter for paging results, or just to
        # return a specific number of content items.
        # See https://developer.kenticocloud.com/v1/reference#listing-response-paging
        #
        # * *Args*:
        #   - *value* (+integer+) The number of content items to return
        #
        # * *Returns*:
        #   - +self+
        def limit(value)
          query_string.set_param('limit', value)
          self
        end

        # Sets the 'elements' query string parameter to limit the elements returned
        # by the query.
        # See https://developer.kenticocloud.com/v1/reference#projection
        #
        # * *Args*:
        #   - *value* (+Array+) A single string or array of strings specifying the desired elements, e.g. %w[price product_name image]
        #
        # * *Returns*:
        #   - +self+
        def elements(value)
          query_string.set_param('elements', value)
          self
        end

        # Sets the 'depth' query string parameter to determine how many levels of
        # linked content items should be returned. By default, only 1 level of depth
        # is used.
        # See https://developer.kenticocloud.com/v1/reference#linked-content
        #
        # * *Args*:
        #   - *value* (+integer+) Level of linked items to be returned
        #
        # * *Returns*:
        #   - +self+
        def depth(value)
          query_string.set_param('depth', value)
          self
        end

        # Allows the request to bypass caching and return the latest content
        # directly from Kentico Kontent.
        # See https://github.com/Kentico/kontent-delivery-sdk-ruby#requesting-the-latest-content
        #
        # * *Returns*:
        #   - +self+
        def request_latest_content
          @headers['X-KC-Wait-For-Loading-New-Content'] = true
          self
        end

        # Uses Kentico::Kontent::Delivery::Builders::UrlBuilder.provide_url to set
        # the URL for the query. The +UrlBuilder+ also validates the URL.
        #
        # * *Raises*:
        #   - +UriFormatException+ if the URL is 65,519 characters or more
        #
        # * *Returns*:
        #   - +string+ The full URL for this query
        def provide_url
          @url = Kentico::Kontent::Delivery::Builders::UrlBuilder.provide_url self if @url.nil?
          Kentico::Kontent::Delivery::Builders::UrlBuilder.validate_url @url
          @url
        end

        # Allows providing custom headers for client requests.
        # See https://github.com/Kentico/kontent-delivery-sdk-ruby#providing-custom-headers
        #
        # * *Args*:
        #   - *headers* (+Hash+) A hash that corresponds to provided headers
        #
        # * *Returns*:
        #   - +self+
        def custom_headers(headers)
          @custom_headers = headers
          self
        end

        private

        # Returns request headers that are extended with custom headers.
        # Custom headers do not override existing headers.
        #
        # * *Returns*
        #   - +Hash+
        def headers
          headers = @headers.clone
          headers['X-KC-SDKID'] = provide_sdk_header
          headers['Authorization'] = "Bearer #{preview_key}" if should_preview
          headers['Authorization'] = "Bearer #{secure_key}" if !should_preview && secure_key

          if @custom_headers
            headers.merge!(@custom_headers) { |key, v1, v2| v1 }
          end

          headers
        end

        # Initializes the +query_string+ attribute with the passed array of
        # Kentico::Kontent::Delivery::QueryParameters::Filter objects.
        #
        # * *Raises*:
        #   - +ArgumentError+ if one the passed objects is not a +Filter+
        def validate_params(query_parameters)
          params = if query_parameters.is_a? Array
                    query_parameters
                  else
                    [query_parameters]
                  end
          params.each do |p|
            query_string.set_param p
            unless p.is_a? Kentico::Kontent::Delivery::QueryParameters::Filter
              raise ArgumentError, ERROR_PARAMS
            end
          end
        end

        def provide_sdk_header
          "rubygems.org;kontent-delivery-sdk-ruby;#{Kentico::Kontent::Delivery::VERSION}"
        end
      end
    end
  end
end
