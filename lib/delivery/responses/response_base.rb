module KenticoCloud
  module Delivery
    module Responses
      # Base class for all responses from a
      # KenticoCloud::Delivery::DeliveryQuery.execute call.
      class ResponseBase
        attr_accessor :http_code,
                      :message,
                      :json

        # Constructor.
        #
        # * *Args*:
        #   - *http_code* (+integer+) The status code returned by the REST request
        #   - *message* (+string+) An informative message about the response, visible when calling +to_s+
        #   - *json* (+string+) _optional_ The complete, unmodified JSON response from the server
        def initialize(http_code, message, json = '')
          self.http_code = http_code
          self.message = message
          self.json = json
        end

        # Provides an informative message about the success of the request
        # by combining the status code and message.
        #
        # * *Returns*:
        #   - +string+
        def to_s
          "Response is status code #{http_code} with message:\n#{message}"
        end
      end
    end
  end
end
