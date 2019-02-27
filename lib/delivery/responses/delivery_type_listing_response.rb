require 'delivery/models/content_type'
require 'delivery/models/pagination'
require 'delivery/responses/response_base'

module Delivery
  module Responses
    # Returned by DeliveryClient.types with an enumerable of ContentTypes
    class DeliveryTypeListingResponse < ResponseBase
      def pagination
        @pagination unless @pagination.nil?
        @pagination = Pagination.new @response['pagination']
      end

      def types
        @types unless @types.nil?
        types = []
        @response['types'].each do |n|
          types << Delivery::ContentType.new(n)
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
