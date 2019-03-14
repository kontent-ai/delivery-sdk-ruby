require 'delivery/models/content_item'
require 'delivery/responses/response_base'

module KenticoCloud
  module Delivery
    module Responses
      # Returned by DeliveryClient.item containing a single ContentItem
      class DeliveryItemResponse < ResponseBase
        def item
          @item unless @item.nil?
          linked_items_resolver = LinkedItemResolver.new @response['modular_content'], @content_link_url_resolver, @inline_content_item_resolver
          @item = KenticoCloud::Delivery::ContentItem.new(
            @response,
            @content_link_url_resolver,
            @inline_content_item_resolver,
            linked_items_resolver
          )
        end

        def initialize(response, content_link_url_resolver, inline_content_item_resolver)
          @response = response
          @content_link_url_resolver = content_link_url_resolver
          @inline_content_item_resolver = inline_content_item_resolver
          super 200,
            "Success, '#{item.system.code_name}' returned",
            JSON.generate(@response)
        end
      end
    end
  end
end
