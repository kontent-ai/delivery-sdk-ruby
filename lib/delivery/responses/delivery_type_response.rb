require 'delivery/models/content_type'
require 'delivery/responses/response_base'

module Kontent
  module Ai
    module Delivery
      module Responses
        # The response of a successful query for a content type.
        # See https://github.com/kontent-ai/delivery-sdk-ruby#retrieving-content-types
        class DeliveryTypeResponse < ResponseBase
          # A Kontent::Ai::Delivery::ContentType object from a
          # Kontent::Ai::Delivery::DeliveryClient.type call.
          #
          # * *Returns*:
          #   - Kontent::Ai::Delivery::ContentType
          def type
            @type unless @type.nil?
            @type = Kontent::Ai::Delivery::ContentType.new(@response)
          end

          def initialize(headers, body)
            @response = JSON.parse(body)
            super 200,
                  "Success, type '#{type.system.codename}' returned",
                  headers,
                  JSON.generate(@response)
          end
        end
      end
    end
  end
end
