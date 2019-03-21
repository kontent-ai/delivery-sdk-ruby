require 'delivery/models/content_type'
require 'delivery/responses/response_base'

module KenticoCloud
  module Delivery
    module Responses
      # The response of a successful query for a content type.
      # See https://github.com/Kentico/delivery-sdk-ruby#retrieving-content-types
      class DeliveryTypeResponse < ResponseBase
        # A KenticoCloud::Delivery::ContentType object from a
        # KenticoCloud::Delivery::DeliveryClient.type call.
        #
        # * *Returns*:
        #   - KenticoCloud::Delivery::ContentType
        def type
          @type unless @type.nil?
          @type = KenticoCloud::Delivery::ContentType.new(@response)
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
