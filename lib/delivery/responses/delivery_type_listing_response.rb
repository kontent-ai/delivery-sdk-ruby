require 'delivery/models/content_type'
require 'delivery/models/pagination'
require 'delivery/responses/response_base'

module Kontent
  module Ai
    module Delivery
      module Responses
        # The response of a successful query for content types.
        # See https://github.com/kontent-ai/delivery-sdk-ruby#retrieving-content-types
        class DeliveryTypeListingResponse < ResponseBase
          # Parses the 'pagination' JSON node of the response.
          #
          # * *Returns*:
          #   - Kontent::Ai::Delivery::Pagination
          def pagination
            @pagination unless @pagination.nil?
            @pagination = Pagination.new @response['pagination']
          end

          # Parses the 'types' JSON node of the response from a
          # Kontent::Ai::Delivery::DeliveryClient.types call.
          #
          # * *Returns*:
          #   - +Array+ The content types as Kontent::Ai::Delivery::ContentType objects
          def types
            @types unless @types.nil?
            types = []
            @response['types'].each do |n|
              types << Kontent::Ai::Delivery::ContentType.new(n)
            end
            @types = types
          end

          def initialize(headers, body)
            @response = JSON.parse(body)
            super 200,
                  "Success, #{types.length} types returned",
                  headers,
                  JSON.generate(@response)
          end
        end
      end
    end
  end
end
