require 'delivery/models/content_type'
require 'delivery/models/pagination'
require 'delivery/responses/response_base'

module KenticoCloud
  module Delivery
    module Responses
      # The response of a successful query for content types.
      # See https://github.com/Kentico/delivery-sdk-ruby#retrieving-content-types
      class DeliveryTypeListingResponse < ResponseBase
        # Parses the 'pagination' JSON node of the response.
        #
        # * *Returns*:
        #   - KenticoCloud::Delivery::Pagination
        def pagination
          @pagination unless @pagination.nil?
          @pagination = Pagination.new @response['pagination']
        end

        # Parses the 'types' JSON node of the response from a
        # KenticoCloud::Delivery::DeliveryClient.types call.
        #
        # * *Returns*:
        #   - +Array+ The content types as KenticoCloud::Delivery::ContentType objects
        def types
          @types unless @types.nil?
          types = []
          @response['types'].each do |n|
            types << KenticoCloud::Delivery::ContentType.new(n)
          end
          @types = types
        end

        def initialize(response)
          @response = response
          super 200,
                "Success, #{types.length} types returned",
                JSON.generate(@response)
        end
      end
    end
  end
end
