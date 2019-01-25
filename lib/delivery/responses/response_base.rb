module Delivery
  module Responses
    # Base class for all responses from DeliveryQuery.execute
    class ResponseBase
      attr_accessor :http_code,
                    :message

      def initialize(http_code, message)
        self.http_code = http_code
        self.message = message
      end

      def to_s
        "Response is status code #{http_code} with message:\n#{message}"
      end
    end
  end
end
