require 'delivery/models/content_item'
require 'delivery/models/pagination'
require 'delivery/responses/response_base'

module Kontent
  module Ai
    module Delivery
      module Responses
        # The response of a successful query for content items.
        # See https://github.com/kontent-ai/delivery-sdk-ruby#listing-items
        class DeliveryItemListingResponse < ResponseBase
          # Parses the 'pagination' JSON node of the response.
          #
          # * *Returns*:
          #   - Kontent::Ai::Delivery::Pagination
          def pagination
            @pagination unless @pagination.nil?
            @pagination = Pagination.new @response['pagination']
          end

          # A collection of Kontent::Ai::Delivery::ContentItem objects from
          # a Kontent::Ai::Delivery::DeliveryClient.items call.
          #
          # * *Returns*:
          #   - +Array+ One or more Kontent::Ai::Delivery::ContentItem objects
          def items
            @items unless @items.nil?
            linked_items_resolver = Kontent::Ai::Delivery::Resolvers::LinkedItemResolver.new @response['modular_content'], @content_link_url_resolver, @inline_content_item_resolver
            items = []
            @response['items'].each do |n|
              items << Kontent::Ai::Delivery::ContentItem.new(
                n,
                @content_link_url_resolver,
                @inline_content_item_resolver,
                linked_items_resolver
              )
            end
            @items = items
          end

          def initialize(headers, body, query)
            @response = JSON.parse(body)
            @content_link_url_resolver = query.content_link_url_resolver
            @inline_content_item_resolver = query.inline_content_item_resolver
            super 200,
              "Success, #{items.length} items returned",
              headers,
              JSON.generate(@response)
          end
        end
      end
    end
  end
end
