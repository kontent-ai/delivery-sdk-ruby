require 'delivery/models/taxonomy_group'
require 'delivery/responses/response_base'

module KenticoCloud
  module Delivery
    module Responses
      # Returned by DeliveryClient.taxonomy containing a single TaxonomyGroup
      class DeliveryTaxonomyResponse < ResponseBase
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
