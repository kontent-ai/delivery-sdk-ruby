require 'delivery/models/content_item'
require 'delivery/responses/response_base'

module Kentico
  module Kontent
    module Delivery
      module Responses
        # The response of a successful query for a content item.
        # See https://github.com/Kentico/kontent-delivery-sdk-ruby#listing-items
        class DeliveryItemResponse < ResponseBase
          # A Kentico::Kontent::Delivery::ContentItem object from a
          # Kentico::Kontent::Delivery::DeliveryClient.item call.
          #
          # * *Returns*:
          #   - Kentico::Kontent::Delivery::ContentItem
          def item
            @item unless @item.nil?
            linked_items_resolver = Kentico::Kontent::Delivery::Resolvers::LinkedItemResolver.new @response['modular_content'], @content_link_url_resolver, @inline_content_item_resolver
            @item = Kentico::Kontent::Delivery::ContentItem.new(
              @response,
              @content_link_url_resolver,
              @inline_content_item_resolver,
              linked_items_resolver
            )
          end

          def initialize(response, content_link_url_resolver, inline_content_item_resolver)
            @response = JSON.parse(response)
            @content_link_url_resolver = content_link_url_resolver
            @inline_content_item_resolver = inline_content_item_resolver
            super 200,
              "Success, '#{item.system.codename}' returned",
              response.headers,
              JSON.generate(@response)
          end
        end
      end
    end
  end
end
