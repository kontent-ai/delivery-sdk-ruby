require 'delivery/models/taxonomy_group'
require 'delivery/responses/response_base'

module KenticoCloud
  module Delivery
    module Responses
      # The response of a successful query for a taxonomy group.
      # See https://github.com/Kentico/delivery-sdk-ruby#taxonomy
      class DeliveryTaxonomyResponse < ResponseBase
        # Parses the response from a
        # KenticoCloud::Delivery::DeliveryClient.taxonomy call.
        #
        # * *Returns*:
        #   - KenticoCloud::Delivery::TaxonomyGroup
        def taxonomy
          @taxonomy unless @taxonomy.nil?
          @taxonomy = KenticoCloud::Delivery::TaxonomyGroup.new(@response)
        end

        def initialize(response)
          @response = response

          super 200,
                "Success, '#{taxonomy.system.codename}' returned",
                JSON.generate(@response)
        end
      end
    end
  end
end
