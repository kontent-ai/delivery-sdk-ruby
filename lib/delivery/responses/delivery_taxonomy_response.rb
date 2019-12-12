require 'delivery/models/taxonomy_group'
require 'delivery/responses/response_base'

module Kentico
  module Kontent
    module Delivery
      module Responses
        # The response of a successful query for a taxonomy group.
        # See https://github.com/Kentico/kontent-delivery-sdk-ruby#taxonomy
        class DeliveryTaxonomyResponse < ResponseBase
          # Parses the response from a
          # Kentico::Kontent::Delivery::DeliveryClient.taxonomy call.
          #
          # * *Returns*:
          #   - Kentico::Kontent::Delivery::TaxonomyGroup
          def taxonomy
            @taxonomy unless @taxonomy.nil?
            @taxonomy = Kentico::Kontent::Delivery::TaxonomyGroup.new(@response)
          end

          def initialize(response)
            @response = JSON.parse(response)

            super 200,
                  "Success, '#{taxonomy.system.codename}' returned",
                  response.headers,
                  JSON.generate(@response)
          end
        end
      end
    end
  end
end
