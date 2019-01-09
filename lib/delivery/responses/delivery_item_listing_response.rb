require 'delivery/models/content_item'

module Delivery
  # Returned by DeliveryClient.items with an enumerable of ContentItems
  class DeliveryItemListingResponse
    def items
      @items unless @items.nil?
      items = []
      @response['items'].each { |n| items << Delivery::ContentItem.new(n) }
      @items = items
    end

    def initialize(response)
      @response = response
    end
  end
end
