require 'delivery/models/content_item'
require 'delivery/models/pagination'
require 'delivery/responses/response_base'

module Kentico
  module Kontent
    module Delivery
      module Responses
        # The response of a successful query for content items.
        # See https://github.com/Kentico/kontent-delivery-sdk-ruby#listing-items
        class DeliveryItemListingResponse < ResponseBase
          # Parses the 'pagination' JSON node of the response.
          #
          # * *Returns*:
          #   - Kentico::Kontent::Delivery::Pagination
          def pagination
            @pagination unless @pagination.nil?
            @pagination = Pagination.new @response['pagination']
          end

          # A collection of Kentico::Kontent::Delivery::ContentItem objects from
          # a Kentico::Kontent::Delivery::DeliveryClient.items call.
          #
          # * *Returns*:
          #   - +Array+ One or more Kentico::Kontent::Delivery::ContentItem objects
          def items
            @items unless @items.nil?
            linked_items_resolver = Kentico::Kontent::Delivery::Resolvers::LinkedItemResolver.new @response['modular_content'], @content_link_url_resolver, @inline_content_item_resolver
            items = []
            @response['items'].each do |n|
              items << Kentico::Kontent::Delivery::ContentItem.new(
                n,
                @content_link_url_resolver,
                @inline_content_item_resolver,
                linked_items_resolver
              )
            end
            @items = items
          end

          def initialize(response, content_link_url_resolver, inline_content_item_resolver)
            @response = JSON.parse(response)
            @content_link_url_resolver = content_link_url_resolver
            @inline_content_item_resolver = inline_content_item_resolver
            super 200,
              "Success, #{items.length} items returned",
              response.headers,
              JSON.generate(@response)
          end
        end
      end
    end
  end
end
