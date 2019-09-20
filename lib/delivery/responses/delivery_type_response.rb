require 'delivery/models/content_type'
require 'delivery/responses/response_base'

module Kentico
  module Kontent
    module Delivery
      module Responses
        # The response of a successful query for a content type.
        # See https://github.com/Kentico/kontent-delivery-sdk-ruby#retrieving-content-types
        class DeliveryTypeResponse < ResponseBase
          # A Kentico::Kontent::Delivery::ContentType object from a
          # Kentico::Kontent::Delivery::DeliveryClient.type call.
          #
          # * *Returns*:
          #   - Kentico::Kontent::Delivery::ContentType
          def type
            @type unless @type.nil?
            @type = Kentico::Kontent::Delivery::ContentType.new(@response)
          end

          def initialize(response)
            @response = response
            super 200,
                  "Success, type '#{type.system.codename}' returned",
                  JSON.generate(@response)
          end
        end
      end
    end
  end
end
