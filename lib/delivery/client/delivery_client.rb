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

    def items(query_parameters = [])
      DeliveryQuery.new(project_id: @project_id, qp: query_parameters)
    end

    def item(code_name, query_parameters = [])
      DeliveryQuery.new(project_id: @project_id, code_name: code_name, qp: query_parameters)
    end
  end
end
