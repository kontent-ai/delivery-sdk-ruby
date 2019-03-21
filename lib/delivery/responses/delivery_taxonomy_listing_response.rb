require 'delivery/models/taxonomy_group'
require 'delivery/models/pagination'
require 'delivery/responses/response_base'

module KenticoCloud
  module Delivery
    module Responses
      # The response of a successful query for taxonomy groups.
      # See https://github.com/Kentico/delivery-sdk-ruby#taxonomy
      class DeliveryTaxonomyListingResponse < ResponseBase
        # Parses the 'pagination' JSON node of the response.
        #
        # * *Returns*:
        #   - KenticoCloud::Delivery::Pagination
        def pagination
          @pagination unless @pagination.nil?
          @pagination = Pagination.new @response['pagination']
        end

        # Parses the 'taxonomies' JSON node of the response from a
        # KenticoCloud::Delivery::DeliveryClient.taxonomies call.
        #
        # * *Returns*:
        #   - +Array+ The taxonomy groups as KenticoCloud::Delivery::TaxonomyGroup objects
        def taxonomies
          @taxonomies unless @taxonomies.nil?
          taxonomies = []
          @response['taxonomies'].each do |n|
            taxonomies << KenticoCloud::Delivery::TaxonomyGroup.new(n)
          end
          @taxonomies = taxonomies
        end

        def initialize(response)
          @response = response

          super 200,
                "Success, #{taxonomies.length} taxonomies returned",
                JSON.generate(@response)
        end
      end
    end
  end
end
