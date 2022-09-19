require 'delivery/responses/response_base'

module Kontent
  module Ai
    module Delivery
      module Responses
        # The response of a successful query of a content type's element
        # See https://github.com/kontent-ai/delivery-sdk-ruby#retrieving-content-type-elements
        class DeliveryElementResponse < ResponseBase
          # An element's definition from a
          # Kontent::Ai::Delivery::DeliveryClient.element call
          #
          # * *Returns*:
          #   - +OpenStruct+ The element of a content item
          def element
            @element unless @element.nil?
            @element = JSON.parse(
              JSON.generate(@response),
              object_class: OpenStruct
            )
          end

          def initialize(headers, body)
            @response = JSON.parse(body)
            super 200,
              "Success, '#{element.codename}' returned",
              headers,
              JSON.generate(@response)
          end
        end
      end
    end
  end
end
