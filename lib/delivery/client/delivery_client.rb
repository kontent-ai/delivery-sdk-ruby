require 'delivery/client/delivery_query'
require 'delivery/responses/delivery_item_listing_response'
require 'delivery/responses/delivery_item_response'
require 'json'

module Delivery
  # Executes requests against the Kentico Cloud Delivery API.
  class DeliveryClient
    def initialize(project_id)
      @project_id = project_id
    end

    def items(*params)
      query = DeliveryQuery.new(@project_id)
      query.params = *params
      DeliveryItemListingResponse.new(JSON.parse(query.execute))
    end

    def item(code_name, *params)
      query = DeliveryQuery.new(@project_id)
      query.code_name = code_name
      query.params = *params
      DeliveryItemResponse.new(JSON.parse(query.execute)['item'])
    end
  end
end
