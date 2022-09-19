require 'delivery/models/content_item'
require 'delivery/models/pagination'
require 'delivery/responses/response_base'

module Kontent
  module Ai
    module Delivery
      module Responses
        # The response of a successful query for content items.
        class DeliveryItemsFeedResponse < ResponseBase
          # A collection of Kontent::Ai::Delivery::ContentItem objects from
          # a Kontent::Ai::Delivery::DeliveryClient.items_feed call.
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
            headers[Kontent::Ai::Delivery::DeliveryQuery::HEADER_CONTINUATION]
          end
        end
      end
    end
  end
end
