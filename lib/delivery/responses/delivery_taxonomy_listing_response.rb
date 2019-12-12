require 'delivery/models/taxonomy_group'
require 'delivery/models/pagination'
require 'delivery/responses/response_base'

module Kentico
  module Kontent
    module Delivery
      module Responses
        # The response of a successful query for taxonomy groups.
        # See https://github.com/Kentico/kontent-delivery-sdk-ruby#taxonomy
        class DeliveryTaxonomyListingResponse < ResponseBase
          # Parses the 'pagination' JSON node of the response.
          #
          # * *Returns*:
          #   - Kentico::Kontent::Delivery::Pagination
          def pagination
            @pagination unless @pagination.nil?
            @pagination = Pagination.new @response['pagination']
          end

          # Parses the 'taxonomies' JSON node of the response from a
          # Kentico::Kontent::Delivery::DeliveryClient.taxonomies call.
          #
          # * *Returns*:
          #   - +Array+ The taxonomy groups as Kentico::Kontent::Delivery::TaxonomyGroup objects
          def taxonomies
            @taxonomies unless @taxonomies.nil?
            taxonomies = []
            @response['taxonomies'].each do |n|
              taxonomies << Kentico::Kontent::Delivery::TaxonomyGroup.new(n)
            end
            @taxonomies = taxonomies
          end

          def initialize(response)
            @response = JSON.parse(response)

            super 200,
                  "Success, #{taxonomies.length} taxonomies returned",
                  response.headers,
                  JSON.generate(@response)
          end
        end
      end
    end
  end
end
