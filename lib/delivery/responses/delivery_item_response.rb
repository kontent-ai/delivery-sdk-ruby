require 'delivery/models/content_item'
require 'delivery/responses/response_base'

module KenticoCloud
  module Delivery
    module Responses
      # The response of a successful query for a content item.
      # See https://github.com/Kentico/delivery-sdk-ruby#listing-items
      class DeliveryItemResponse < ResponseBase
        # A KenticoCloud::Delivery::ContentItem object from a
        # KenticoCloud::Delivery::DeliveryClient.item call.
        #
        # * *Returns*:
        #   - KenticoCloud::Delivery::ContentItem
        def item
          @item unless @item.nil?
          linked_items_resolver = KenticoCloud::Delivery::Resolvers::LinkedItemResolver.new @response['modular_content'], @content_link_url_resolver, @inline_content_item_resolver
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
            "Success, '#{item.system.codename}' returned",
            JSON.generate(@response)
        end
      end
    end
  end
end
