require 'delivery/models/content_item'
require 'delivery/models/pagination'
require 'delivery/responses/response_base'

module Kentico
  module Kontent
    module Delivery
      module Responses
        # The response of a successful query for content items.
        class DeliveryItemsFeedResponse < ResponseBase
          # A collection of Kentico::Kontent::Delivery::ContentItem objects from
          # a Kentico::Kontent::Delivery::DeliveryClient.items_feed call.
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

          def initialize(headers, body, query)
            @query = query
            @response = JSON.parse(body)
            @content_link_url_resolver = query.content_link_url_resolver
            @inline_content_item_resolver = query.inline_content_item_resolver
            super 200,
              "Success, #{items.length} items returned",
              headers,
              JSON.generate(@response)
          end

          def next_result
            @query.update_continuation continuation_token
            @query.execute
          end

          def more_results?
            !continuation_token.nil?
          end

          def continuation_token
            headers[Kentico::Kontent::Delivery::DeliveryQuery::HEADER_CONTINUATION]
          end
        end
      end
    end
  end
end
