require 'delivery/models/content_type'
require 'delivery/models/pagination'
require 'delivery/responses/response_base'

module Kentico
  module Kontent
    module Delivery
      module Responses
        # The response of a successful query for content types.
        # See https://github.com/Kentico/kontent-delivery-sdk-ruby#retrieving-content-types
        class DeliveryTypeListingResponse < ResponseBase
          # Parses the 'pagination' JSON node of the response.
          #
          # * *Returns*:
          #   - Kentico::Kontent::Delivery::Pagination
          def pagination
            @pagination unless @pagination.nil?
            @pagination = Pagination.new @response['pagination']
          end

          # Parses the 'types' JSON node of the response from a
          # Kentico::Kontent::Delivery::DeliveryClient.types call.
          #
          # * *Returns*:
          #   - +Array+ The content types as Kentico::Kontent::Delivery::ContentType objects
          def types
            @types unless @types.nil?
            types = []
            @response['types'].each do |n|
              types << Kentico::Kontent::Delivery::ContentType.new(n)
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
