require 'delivery/models/content_item'

module Delivery
  # Returned by DeliveryClient.item containing a single ContentItem
  class DeliveryItemResponse
    def item
      @item unless @item.nil?
      @item = Delivery::ContentItem.new(@response, @content_link_url_resolver)
    end

    def initialize(response, content_link_url_resolver)
      @response = response
      @content_link_url_resolver = content_link_url_resolver
    end
  end
end
