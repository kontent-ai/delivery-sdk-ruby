require 'delivery/responses/response_base'

module Delivery
  module Responses
    # Returned by DeliveryClient.element containing a single element
    class DeliveryElementResponse < ResponseBase
      def element
        @element unless @element.nil?
        @element = JSON.parse(
          JSON.generate(@response),
          object_class: OpenStruct
        )
      end

      def initialize(response)
        @response = response
        super 200,
          "Success, '#{element.codename}' returned",
          JSON.generate(@response)
      end
    end
  end
end
