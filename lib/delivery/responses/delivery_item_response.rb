require 'delivery/models/content_item'
require 'delivery/responses/response_base'

module Kontent
  module Ai
    module Delivery
      module Responses
        # The response of a successful query for a content item.
        # See https://github.com/kontent-ai/delivery-sdk-ruby#listing-items
        class DeliveryItemResponse < ResponseBase
          # A Kontent::Ai::Delivery::ContentItem object from a
          # Kontent::Ai::Delivery::DeliveryClient.item call.
          #
          # * *Returns*:
          #   - Kontent::Ai::Delivery::ContentItem
          def item
            @item unless @item.nil?
            linked_items_resolver = Kontent::Ai::Delivery::Resolvers::LinkedItemResolver.new @response['modular_content'], @content_link_url_resolver, @inline_content_item_resolver
            @item = Kontent::Ai::Delivery::ContentItem.new(
              @response,
              @content_link_url_resolver,
              @inline_content_item_resolver,
              linked_items_resolver
            )
          end

          def initialize(headers, body, query)
            @response = JSON.parse(body)
            @content_link_url_resolver = query.content_link_url_resolver
            @inline_content_item_resolver = query.inline_content_item_resolver
            super 200,
              "Success, '#{item.system.codename}' returned",
              headers,
              JSON.generate(@response)
          end
        end
      end
    end
  end
end
