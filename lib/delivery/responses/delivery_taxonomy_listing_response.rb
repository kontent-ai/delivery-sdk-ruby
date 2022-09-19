require 'delivery/models/taxonomy_group'
require 'delivery/models/pagination'
require 'delivery/responses/response_base'

module Kontent
  module Ai
    module Delivery
      module Responses
        # The response of a successful query for taxonomy groups.
        # See https://github.com/kontent-ai/delivery-sdk-ruby#taxonomy
        class DeliveryTaxonomyListingResponse < ResponseBase
          # Parses the 'pagination' JSON node of the response.
          #
          # * *Returns*:
          #   - Kontent::Ai::Delivery::Pagination
          def pagination
            @pagination unless @pagination.nil?
            @pagination = Pagination.new @response['pagination']
          end

          # Parses the 'taxonomies' JSON node of the response from a
          # Kontent::Ai::Delivery::DeliveryClient.taxonomies call.
          #
          # * *Returns*:
          #   - +Array+ The taxonomy groups as Kontent::Ai::Delivery::TaxonomyGroup objects
          def taxonomies
            @taxonomies unless @taxonomies.nil?
            taxonomies = []
            @response['taxonomies'].each do |n|
              taxonomies << Kontent::Ai::Delivery::TaxonomyGroup.new(n)
            end
            @taxonomies = taxonomies
          end

          def initialize(headers, body)
            @response = JSON.parse(body)

            super 200,
                  "Success, #{taxonomies.length} taxonomies returned",
                  headers,
                  JSON.generate(@response)
          end
        end
      end
    end
  end
end
