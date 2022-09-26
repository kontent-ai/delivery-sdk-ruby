require 'rest-client'

module Kontent
  module Ai
    module Delivery
      class RequestManager
        class << self
          MAX_ATTEMPTS = 6
          MAX_DELAY_SECONDS = 30
          INITIAL_DELAY = 1
          RETRY_WHEN_CODE = [408, 429, 500, 502, 503, 504].freeze
          CODES_WITH_POSSIBLE_RETRY_HEADER = [429, 503].freeze

          def start(query, headers)
            @query = query
            @headers = headers
            @times_run = 1
            @delay = INITIAL_DELAY
            @url = @query.provide_url
            @total_delay = 0
            continue
          end

          private

          def should_retry(potential_response)
            return potential_response if @times_run == MAX_ATTEMPTS ||
                                         !RETRY_WHEN_CODE.include?(potential_response.http_code) ||
                                         !@query.with_retry_policy ||
                                         @total_delay >= MAX_DELAY_SECONDS

            next_delay
            sleep(@delay)
            @total_delay += @delay
            continue
          end

          # Generates a random delay based on times_run, then increases times_run
          def next_delay
            min = 0.8 * INITIAL_DELAY
            max = (1.2 * INITIAL_DELAY) * (2**@times_run)
            @delay = rand(min..max)
            @times_run += 1
          end

          def continue
            if ENV['TEST'] == '1'
              resp = Kontent::Ai::Delivery::Tests::FakeResponder.get_response @query, @url, @headers
              return should_retry(resp) if resp.is_a? Kontent::Ai::Delivery::Responses::ResponseBase

              make_response resp # resp is pure JSON
            else
              begin
                resp = RestClient.get @url, @headers
              rescue RestClient::ExceptionWithResponse => err
                should_retry Kontent::Ai::Delivery::Responses::ResponseBase.new err.http_code, err.response
              rescue RestClient::SSLCertificateNotVerified => err
                should_retry Kontent::Ai::Delivery::Responses::ResponseBase.new 500, err
              rescue SocketError => err
                should_retry Kontent::Ai::Delivery::Responses::ResponseBase.new 500, err.message
              else
                make_response resp
              end
            end
          end

          # Converts a standard REST response based on the type of query.
          #
          # * *Returns*:
          #   - An object derived from the Kontent::Ai::Delivery::Responses::ResponseBase class
          def make_response(response)
            case @query.query_type
            when Kontent::Ai::Delivery::QUERY_TYPE_ITEMS_FEED
              Kontent::Ai::Delivery::Responses::DeliveryItemsFeedResponse.new(
                response.headers,
                response.body,
                @query
              )
            when Kontent::Ai::Delivery::QUERY_TYPE_ITEMS
              respond_item response
            when Kontent::Ai::Delivery::QUERY_TYPE_TYPES
              respond_type response
            when Kontent::Ai::Delivery::QUERY_TYPE_TAXONOMIES
              respond_taxonomy response
            when Kontent::Ai::Delivery::QUERY_TYPE_ELEMENT
              Kontent::Ai::Delivery::Responses::DeliveryElementResponse.new response.headers, response.body
            when Kontent::Ai::Delivery::QUERY_TYPE_LANGUAGES
              Kontent::Ai::Delivery::Responses::DeliveryLanguageListingResponse.new response.headers, response.body
            end
          end

          def respond_type(response)
            if @query.code_name.nil?
              Kontent::Ai::Delivery::Responses::DeliveryTypeListingResponse.new response.headers, response.body
            else
              Kontent::Ai::Delivery::Responses::DeliveryTypeResponse.new response.headers, response.body
            end
          end

          def respond_taxonomy(response)
            if @query.code_name.nil?
              Kontent::Ai::Delivery::Responses::DeliveryTaxonomyListingResponse.new response.headers, response.body
            else
              Kontent::Ai::Delivery::Responses::DeliveryTaxonomyResponse.new response.headers, response.body
            end
          end

          def respond_item(response)
            if @query.code_name.nil?
              Kontent::Ai::Delivery::Responses::DeliveryItemListingResponse.new(
                response.headers,
                response.body,
                @query
              )
            else
              Kontent::Ai::Delivery::Responses::DeliveryItemResponse.new(
                response.headers,
                response.body,
                @query
              )
            end
          end
        end
      end
    end
  end
end