require 'rest-client'

module KenticoCloud
  module Delivery
    class RequestManager
      class << self
        MAX_ATTEMPTS = 6
        INITIAL_DELAY = 0.2
        RETRY_WHEN_CODE = [408, 500, 502, 503, 504].freeze

        def start(query, headers)
          @query = query
          @headers = headers
          @times_run = 1
          @delay = INITIAL_DELAY
          @url = @query.provide_url
          continue
        end

        private

        def should_retry(potential_response)
          return potential_response if @times_run == MAX_ATTEMPTS ||
                                       !RETRY_WHEN_CODE.include?(potential_response.http_code) ||
                                       !@query.with_retry_policy

          @times_run += 1
          @delay *= 2
          sleep(@delay)
          continue
        end

        def continue
          resp = RestClient.get @url, @headers
        rescue RestClient::ExceptionWithResponse => err
          should_retry KenticoCloud::Delivery::Responses::ResponseBase.new err.http_code, err.response
        rescue RestClient::SSLCertificateNotVerified => err
          should_retry KenticoCloud::Delivery::Responses::ResponseBase.new 500, err
        rescue SocketError => err
          should_retry KenticoCloud::Delivery::Responses::ResponseBase.new 500, err.message
        else
          make_response resp
        end

        # Converts a standard REST response based on the type of query.
        #
        # * *Returns*:
        #   - An object derived from the KenticoCloud::Delivery::Responses::ResponseBase class
        def make_response(response)
          case @query.query_type
          when KenticoCloud::Delivery::QUERY_TYPE_ITEMS
            respond_item response
          when KenticoCloud::Delivery::QUERY_TYPE_TYPES
            respond_type response
          when KenticoCloud::Delivery::QUERY_TYPE_TAXONOMIES
            respond_taxonomy response
          when KenticoCloud::Delivery::QUERY_TYPE_ELEMENT
            KenticoCloud::Delivery::Responses::DeliveryElementResponse.new JSON.parse(response)
          end
        end

        def respond_type(response)
          if @query.code_name.nil?
            KenticoCloud::Delivery::Responses::DeliveryTypeListingResponse.new JSON.parse(response)
          else
            KenticoCloud::Delivery::Responses::DeliveryTypeResponse.new JSON.parse(response)
          end
        end

        def respond_taxonomy(response)
          if @query.code_name.nil?
            KenticoCloud::Delivery::Responses::DeliveryTaxonomyListingResponse.new JSON.parse(response)
          else
            KenticoCloud::Delivery::Responses::DeliveryTaxonomyResponse.new JSON.parse(response)
          end
        end

        def respond_item(response)
          if @query.code_name.nil?
            KenticoCloud::Delivery::Responses::DeliveryItemListingResponse.new(
              JSON.parse(response),
              @query.content_link_url_resolver,
              @query.inline_content_item_resolver
            )
          else
            KenticoCloud::Delivery::Responses::DeliveryItemResponse.new(
              JSON.parse(response),
              @query.content_link_url_resolver,
              @query.inline_content_item_resolver
            )
          end
        end
      end
    end
  end
end