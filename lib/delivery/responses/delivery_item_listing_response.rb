require 'delivery/models/content_item'
require 'delivery/models/pagination'
require 'delivery/responses/response_base'

module KenticoCloud
  module Delivery
    module Responses
      # The response of a successful query for content items.
      # See https://github.com/Kentico/delivery-sdk-ruby#listing-items
      class DeliveryItemListingResponse < ResponseBase
        # Parses the 'pagination' JSON node of the response.
        #
        # * *Returns*:
        #   - KenticoCloud::Delivery::Pagination
        def pagination
          @pagination unless @pagination.nil?
          @pagination = Pagination.new @response['pagination']
        end

        # A collection of KenticoCloud::Delivery::ContentItem objects from
        # a KenticoCloud::Delivery::DeliveryClient.items call.
        #
        # * *Returns*:
        #   - +Array+ One or more KenticoCloud::Delivery::ContentItem objects
        def items
          @items unless @items.nil?
          linked_items_resolver = KenticoCloud::Delivery::Resolvers::LinkedItemResolver.new @response['modular_content'], @content_link_url_resolver, @inline_content_item_resolver
          items = []
          @response['items'].each do |n|
            items << KenticoCloud::Delivery::ContentItem.new(
              n,
              @content_link_url_resolver,
              @inline_content_item_resolver,
              linked_items_resolver
            )
          end
          @items = items
        end

        def initialize(response, content_link_url_resolver, inline_content_item_resolver)
          @response = response
          @content_link_url_resolver = content_link_url_resolver
          @inline_content_item_resolver = inline_content_item_resolver
          super 200,
            "Success, #{items.length} items returned",
            JSON.generate(@response)
        end
      end
    end
  end
end
