require 'delivery/models/content_item'
require 'delivery/models/pagination'

module Delivery
  # Returned by DeliveryClient.items with an enumerable of ContentItems
  class DeliveryItemListingResponse
    def pagination
      @pagination unless @pagination.nil?
      @pagination = Pagination.new @response['pagination']
    end

    def items
      @items unless @items.nil?
      items = []
      @response['items'].each { |n| items << Delivery::ContentItem.new(n, @content_link_url_resolver) }
      @items = items
    end

    def initialize(response, content_link_url_resolver)
      @response = response
      @content_link_url_resolver = content_link_url_resolver
    end
  end
end
