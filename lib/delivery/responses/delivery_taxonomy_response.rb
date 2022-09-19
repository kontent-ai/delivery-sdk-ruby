require 'delivery/models/taxonomy_group'
require 'delivery/responses/response_base'

module Kontent
  module Ai
    module Delivery
      module Responses
        # The response of a successful query for a taxonomy group.
        # See https://github.com/kontent-ai/delivery-sdk-ruby#taxonomy
        class DeliveryTaxonomyResponse < ResponseBase
          # Parses the response from a
          # Kontent::Ai::Delivery::DeliveryClient.taxonomy call.
          #
          # * *Returns*:
          #   - Kontent::Ai::Delivery::TaxonomyGroup
          def taxonomy
            @taxonomy unless @taxonomy.nil?
            @taxonomy = Kontent::Ai::Delivery::TaxonomyGroup.new(@response)
          end

          def initialize(headers, body)
            @response = JSON.parse(body)

            super 200,
                  "Success, '#{taxonomy.system.codename}' returned",
                  headers,
                  JSON.generate(@response)
          end
        end
      end
    end
  end
end
