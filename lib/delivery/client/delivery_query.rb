require 'rest-client'
require 'delivery/builders/url_builder'
require 'delivery/query_parameters/query_string'
require 'delivery/version'

module KenticoCloud
  module Delivery
    # Responsible for translating query parameters into the
    # corresponding REST request to Kentico Cloud.
    class DeliveryQuery
      ERROR_PREVIEW = 'Preview is enabled for the query, but the key is null. '\
                      'You can set the preview_key attribute of the query, or '\
                      'when you initialize the client. See '\
                      'https://github.com/Kentico/delivery-sdk-ruby#previewing-unpublished-content'.freeze
      ERROR_PARAMS = 'Only filters may be passed in the .item or .items methods'\
                      '. See https://github.com/Kentico/delivery-sdk-ruby#filtering'.freeze
      attr_accessor :use_preview,
                    :preview_key,
                    :project_id,
                    :code_name,
                    :secure_key,
                    :content_link_url_resolver,
                    :inline_content_item_resolver,
                    :query_type,
                    :query_string,
                    :content_type

      # Setter for url, returns self for chaining
      # .url represents *manually* configured urls, otherwise final url is
      # generated in .execute and this will return nil
      def url(url = nil)
        @url = url unless url.nil?
        self
      end

      def initialize(config)
        @headers = {}

        # Map each hash value to attr with corresponding key
        # from https://stackoverflow.com/a/2681014/5656214
        config.each do |k, v|
          instance_variable_set("@#{k}", v) unless v.nil?
        end
        self.query_string = KenticoCloud::Delivery::QueryParameters::QueryString.new
        return if config.fetch(:qp, nil).nil?

        # Query parameters were passed, parse and validate
        validate_params config.fetch(:qp)
      end

      def execute
        provide_url
        begin
          resp = execute_rest
        rescue RestClient::ExceptionWithResponse => err
          resp = KenticoCloud::Delivery::Responses::ResponseBase.new err.http_code, err.response
        rescue RestClient::SSLCertificateNotVerified => err
          resp = KenticoCloud::Delivery::Responses::ResponseBase.new 500, err
        rescue SocketError => err
          resp = KenticoCloud::Delivery::Responses::ResponseBase.new 500, err.message
        else
          resp = make_response resp
        ensure
          yield resp if block_given?
          resp
        end
      end

      def with_link_resolver(resolver)
        self.content_link_url_resolver = resolver
        self
      end

      def with_inline_content_item_resolver(resolver)
        self.inline_content_item_resolver = resolver
        self
      end

      def order_by(value, sort = '[asc]')
        query_string.set_param('order', value + sort)
        self
      end

      def skip(value)
        query_string.set_param('skip', value)
        self
      end

      def language(value)
        query_string.set_param('language', value)
      end

      def limit(value)
        query_string.set_param('limit', value)
        self
      end

      def elements(value)
        query_string.set_param('elements', value)
        self
      end

      def depth(value)
        query_string.set_param('depth', value)
        self
      end

      def request_latest_content
        @headers['X-KC-Wait-For-Loading-New-Content'] = true
        self
      end

      private

      def provide_url
        @url = KenticoCloud::Delivery::Builders::UrlBuilder.provide_url self if @url.nil?
        KenticoCloud::Delivery::Builders::UrlBuilder.validate_url @url
      end

      def validate_params(query_parameters)
        params = if query_parameters.is_a? Array
                  query_parameters
                else
                  [query_parameters]
                end
        params.each do |p|
          query_string.set_param p
          unless p.is_a? KenticoCloud::Delivery::QueryParameters::Filter
            raise ArgumentError, ERROR_PARAMS
          end
        end
      end

      # Returns true if this query should use preview mode. Raises an error if
      # preview is enabled, but the key is nil
      def should_preview
        raise ERROR_PREVIEW if use_preview && preview_key.nil?

        use_preview && !preview_key.nil?
      end

      def execute_rest
        headers = @headers.clone

        headers['X-KC-SDKID'] = provide_sdk_header
        headers['Authorization'] = "Bearer #{preview_key}" if should_preview
        headers['Authorization'] = "Bearer #{secure_key}" if !should_preview && secure_key

        RestClient.get @url, headers
      end

      def provide_sdk_header
        "rubygems.org;delivery-sdk-ruby;#{KenticoCloud::Delivery::VERSION}"
      end

      def make_response(response)
        case query_type
        when KenticoCloud::Delivery::QUERY_TYPE_ITEMS
          if code_name.nil?
            KenticoCloud::Delivery::Responses::DeliveryItemListingResponse.new(
              JSON.parse(response),
              content_link_url_resolver,
              inline_content_item_resolver
            )
          else
            KenticoCloud::Delivery::Responses::DeliveryItemResponse.new(
              JSON.parse(response),
              content_link_url_resolver,
              inline_content_item_resolver
            )
          end
        when KenticoCloud::Delivery::QUERY_TYPE_TYPES
          if code_name.nil?
            KenticoCloud::Delivery::Responses::DeliveryTypeListingResponse.new JSON.parse(response)
          else
            KenticoCloud::Delivery::Responses::DeliveryTypeResponse.new JSON.parse(response)
          end
        when KenticoCloud::Delivery::QUERY_TYPE_TAXONOMIES
          if code_name.nil?
            KenticoCloud::Delivery::Responses::DeliveryTaxonomyListingResponse.new JSON.parse(response)
          else
            KenticoCloud::Delivery::Responses::DeliveryTaxonomyResponse.new JSON.parse(response)
          end
        when KenticoCloud::Delivery::QUERY_TYPE_ELEMENT
          KenticoCloud::Delivery::Responses::DeliveryElementResponse.new JSON.parse(response)
        end
      end
    end
  end
end
