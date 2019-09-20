module Kentico
  module Kontent
    module Delivery
      module Builders
        # Internal class which generates the URL required for Delivery REST API
        class UrlBuilder
          URL_TEMPLATE_BASE = 'https://deliver.kontent.ai/%s'.freeze
          URL_TEMPLATE_PREVIEW = 'https://preview-deliver.kontent.ai/%s'.freeze
          URL_TEMPLATE_ITEM = '/items/%s'.freeze
          URL_TEMPLATE_ITEMS = '/items'.freeze
          URL_TEMPLATE_TYPE = '/types/%s'.freeze
          URL_TEMPLATE_TYPES = '/types'.freeze
          URL_TEMPLATE_ELEMENTS = '/types/%s/elements/%s'.freeze
          URL_TEMPLATE_TAXONOMY = '/taxonomies/%s'.freeze
          URL_TEMPLATE_TAXONOMIES = '/taxonomies'.freeze

          URL_MAX_LENGTH = 65_519
          MSG_LONG_QUERY = 'The request url is too long. Split your query into multiple calls.'.freeze

          class << self
            # Returns the proper domain for the request along with the
            # query string parameters configured by the +DeliveryQuery+.
            #
            # * *Args*:
            #   - *query* ( Kentico::Kontent::Delivery::DeliveryQuery )
            #
            # * *Returns*:
            #   - +string+ The full URL for a Delivery request
            def provide_url(query)
              url = provide_base_url(query)
              url += provide_path_part(query)

              if query.query_string.empty?
                url
              else
                url + query.query_string.to_s
              end
            end

            # Checks whether the provided URL is too long and raises an error if so.
            #
            # * *Args*:
            #   - *url* (+string+) A full Delivery URL
            #
            # * *Raises*:
            #   - +UriFormatException+ if the URL is 65,519 characters or more
            def validate_url(url)
              raise UriFormatException, MSG_LONG_QUERY if url.length > URL_MAX_LENGTH
            end

            private

            # Returns relative path part of URL depending on query type.
            #
            # * *Args*:
            #   - *query* ( Kentico::Kontent::Delivery::DeliveryQuery )
            #
            # * *Returns*:
            #   - +string+ The URL path part (without protocol or domain)
            def provide_path_part(query)
              case query.query_type
              when Kentico::Kontent::Delivery::QUERY_TYPE_ITEMS
                provide_item query
              when Kentico::Kontent::Delivery::QUERY_TYPE_TYPES
                provide_type query
              when Kentico::Kontent::Delivery::QUERY_TYPE_TAXONOMIES
                provide_taxonomy query
              when Kentico::Kontent::Delivery::QUERY_TYPE_ELEMENT
                format(URL_TEMPLATE_ELEMENTS, query.content_type, query.code_name)
              end
            end

            def provide_item(query)
              if query.code_name.nil?
                URL_TEMPLATE_ITEMS
              else
                format(URL_TEMPLATE_ITEM, query.code_name)
              end
            end

            def provide_taxonomy(query)
              if query.code_name.nil?
                URL_TEMPLATE_TAXONOMIES
              else
                format(URL_TEMPLATE_TAXONOMY, query.code_name)
              end
            end

            def provide_type(query)
              if query.code_name.nil?
                URL_TEMPLATE_TYPES
              else
                format(URL_TEMPLATE_TYPE, query.code_name)
              end
            end

            # Returns the protocol and domain with project ID. Domain changes
            # according to the query's +use_preview+ attribute.
            #
            # * *Args*:
            #   - *query* ( Kentico::Kontent::Delivery::DeliveryQuery )
            #
            # * *Returns*:
            #   - +string+ The URL with the project ID
            def provide_base_url(query)
              if query.use_preview
                format(URL_TEMPLATE_PREVIEW, query.project_id)
              else
                format(URL_TEMPLATE_BASE, query.project_id)
              end
            end
          end
        end
      end
    end
  end
end
