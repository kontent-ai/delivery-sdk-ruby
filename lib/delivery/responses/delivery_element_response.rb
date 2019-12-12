require 'delivery/responses/response_base'

module Kentico
  module Kontent
    module Delivery
      module Responses
        # The response of a successful query of a content type's element
        # See https://github.com/Kentico/kontent-delivery-sdk-ruby#retrieving-content-type-elements
        class DeliveryElementResponse < ResponseBase
          # An element's definition from a
          # Kentico::Kontent::Delivery::DeliveryClient.element call
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

          def initialize(response)
            @response = JSON.parse(response)
            super 200,
              "Success, '#{element.codename}' returned",
              response.headers,
              JSON.generate(@response)
          end
        end
      end
    end
  end
end
