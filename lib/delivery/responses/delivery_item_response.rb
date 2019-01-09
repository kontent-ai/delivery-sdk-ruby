require 'delivery/models/content_item'

module Delivery
  # Returned by DeliveryClient.item containing a single ContentItem
  class DeliveryItemResponse
    def item
      @item unless @item.nil?
      @item = Delivery::ContentItem.new(@response)
    end

    def initialize(response)
      @response = response
    end
  end
end
