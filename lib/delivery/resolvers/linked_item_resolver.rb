module Kentico
  module Kontent
    module Delivery
      module Resolvers
        # Resolves a content item by its codename. It contains the modular content
        # of item/items response.
        class LinkedItemResolver
          def initialize(modular_content, content_link_url_resolver, inline_content_item_resolver)
            @modular_content = modular_content
            @content_link_url_resolver = content_link_url_resolver
            @inline_content_item_resolver = inline_content_item_resolver
            @resolved_items = {}
          end

          # Resolves a content item. If the link for a codename was resolved
          # before, it returns the same instance of ContentItem.
          #
          # * *Args*:
          #   - *codename* (+string+) Codename of the content item
          #
          # * *Return*:
          #   - Kentico::Kontent::Delivery::ContentItem
          def resolve(codename)
            @resolved_items[codename] ||= resolve_item(codename)
          end

          private

          def resolve_item(codename)
            item = @modular_content.values.find { |i| i['system']['codename'] == codename }
            ContentItem.new JSON.parse(JSON.generate(item)), @content_link_url_resolver, @inline_content_item_resolver, self
          end
        end
      end
    end
  end
end
