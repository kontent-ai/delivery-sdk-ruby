require 'delivery/models/content_type'
require 'delivery/responses/response_base'

module KenticoCloud
  module Delivery
    module Responses
      # Returned by DeliveryClient.types with an enumerable of ContentTypes
      class DeliveryTypeResponse < ResponseBase
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
