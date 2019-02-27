require 'delivery/models/taxonomy_group'
require 'delivery/models/pagination'
require 'delivery/responses/response_base'

module Delivery
  module Responses
    # Returned by DeliveryClient.taxonomies with an enumerable of TaxonomyGroups
    class DeliveryTaxonomyListingResponse < ResponseBase
      def pagination
        @pagination unless @pagination.nil?
        @pagination = Pagination.new @response['pagination']
      end

      def taxonomies
        @taxonomies unless @taxonomies.nil?
        taxonomies = []
        @response['taxonomies'].each do |n|
          taxonomies << Delivery::TaxonomyGroup.new(n)
        end
        @taxonomies = taxonomies
      end

      def initialize(response)
        @response = response

        super 200,
              "Success,
          #{taxonomies.length} taxonomies returned",
              JSON.generate(@response)
      end
    end
  end
end
