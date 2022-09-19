require 'delivery/client/delivery_query'
require 'delivery/responses/delivery_item_listing_response'
require 'delivery/responses/delivery_item_response'
require 'json'

module Kontent
  module Ai
    module Delivery
      QUERY_TYPE_TYPES = 'QUERY_TYPE_TYPES'.freeze
      QUERY_TYPE_ITEMS = 'QUERY_TYPE_ITEMS'.freeze
      QUERY_TYPE_TAXONOMIES = 'QUERY_TYPE_TAXONOMIES'.freeze
      QUERY_TYPE_ELEMENT = 'QUERY_TYPE_ELEMENT'.freeze
      QUERY_TYPE_ITEMS_FEED = 'QUERY_TYPE_ITEMS_FEED'.freeze
      QUERY_TYPE_LANGUAGES = 'QUERY_TYPE_LANGUAGES'.freeze

      # Executes requests against the Kontent.ai Delivery API.
      class DeliveryClient
        attr_accessor :use_preview

        # Constructor. Accepts a hash with the options for client.
        #
        # * *Args*:
        #   - *config* (+Hash+) May contain the following keys:
        #     - project_id (+string+) _required_
        #     - preview_key (+string+)
        #     - secure_key (+string+)
        #     - content_link_url_resolver ( Kontent::Ai::Delivery::Resolvers::ContentLinkResolver )
        #     - inline_content_item_resolver ( Kontent::Ai::Delivery::Resolvers::InlineContentItemResolver )
        #     - with_retry_policy (+bool+)
        def initialize(config)
          @project_id = config.fetch(:project_id)
          @preview_key = config.fetch(:preview_key, nil)
          @secure_key = config.fetch(:secure_key, nil)
          @content_link_url_resolver = config.fetch(:content_link_url_resolver, nil)
          @inline_content_item_resolver = config.fetch(:inline_content_item_resolver, nil)
          @with_retry_policy = config.fetch(:with_retry_policy, true)
          self.use_preview = !@preview_key.nil?
        end

        # Return all content types of the project
        #
        # * *Returns*:
        #   - Kontent::Ai::Delivery::DeliveryQuery
        def types
          DeliveryQuery.new project_id: @project_id,
                            secure_key: @secure_key,
                            query_type: QUERY_TYPE_TYPES,
                            with_retry_policy: @with_retry_policy
        end

        # Return a single content type of the project
        #
        # * *Args*:
        #   - *code_name* (+string+) Code name of the desired content type
        #
        # * *Returns*:
        #   - Kontent::Ai::Delivery::DeliveryQuery
        def type(code_name)
          DeliveryQuery.new project_id: @project_id,
                            secure_key: @secure_key,
                            code_name: code_name,
                            query_type: QUERY_TYPE_TYPES,
                            with_retry_policy: @with_retry_policy
        end

        # Return a paginated feed of all content items of the project
        #
        # * *Args*:
        #   - *query_parameters* (+Array+) _optional_ One or more Kontent::Ai::Delivery::QueryParameters::Filter objects. A single object will automatically be converted into an Array.
        #
        # * *Returns*:
        #   - Kontent::Ai::Delivery::DeliveryQuery
        def items_feed(query_parameters = [])
          q = DeliveryQuery.new project_id: @project_id,
                                secure_key: @secure_key,
                                qp: query_parameters,
                                content_link_url_resolver: @content_link_url_resolver,
                                inline_content_item_resolver: @inline_content_item_resolver,
                                query_type: QUERY_TYPE_ITEMS_FEED,
                                with_retry_policy: @with_retry_policy
          q.use_preview = use_preview
          q.preview_key = @preview_key
          q
        end

        # Return all content items of the project
        #
        # * *Args*:
        #   - *query_parameters* (+Array+) _optional_ One or more Kontent::Ai::Delivery::QueryParameters::Filter objects. A single object will automatically be converted into an Array.
        #
        # * *Returns*:
        #   - Kontent::Ai::Delivery::DeliveryQuery
        def items(query_parameters = [])
          q = DeliveryQuery.new project_id: @project_id,
                                secure_key: @secure_key,
                                qp: query_parameters,
                                content_link_url_resolver: @content_link_url_resolver,
                                inline_content_item_resolver: @inline_content_item_resolver,
                                query_type: QUERY_TYPE_ITEMS,
                                with_retry_policy: @with_retry_policy
          q.use_preview = use_preview
          q.preview_key = @preview_key
          q
        end

        # Return a single content item of the project
        #
        # * *Args*:
        #   - *code_name* (+string+) The code name of the desired content item
        #   - *query_parameters* (+Array+) _optional_ One or more Kontent::Ai::Delivery::QueryParameters::Filter objects. A single object will automatically be converted into an Array.
        #
        # * *Returns*:
        #   - Kontent::Ai::Delivery::DeliveryQuery
        def item(code_name, query_parameters = [])
          q = DeliveryQuery.new project_id: @project_id,
                                secure_key: @secure_key,
                                code_name: code_name,
                                qp: query_parameters,
                                content_link_url_resolver: @content_link_url_resolver,
                                inline_content_item_resolver: @inline_content_item_resolver,
                                query_type: QUERY_TYPE_ITEMS,
                                with_retry_policy: @with_retry_policy
          q.use_preview = use_preview
          q.preview_key = @preview_key
          q
        end

        # Return all taxonomy groups of the project
        #
        # * *Args*:
        #   - *query_parameters* (+Array+) _optional_ One or more Kontent::Ai::Delivery::QueryParameters::Filter objects. A single object will automatically be converted into an Array.
        #
        # * *Returns*:
        #   - Kontent::Ai::Delivery::DeliveryQuery
        def taxonomies(query_parameters = [])
          DeliveryQuery.new project_id: @project_id,
                            secure_key: @secure_key,
                            qp: query_parameters,
                            query_type: QUERY_TYPE_TAXONOMIES,
                            with_retry_policy: @with_retry_policy
        end

        # Return a single taxonomy group of the project
        #
        # * *Args*:
        #   - *code_name* (+string+) The code name of the desired taxonomy group
        #
        # * *Returns*:
        #   - Kontent::Ai::Delivery::DeliveryQuery
        def taxonomy(code_name)
          DeliveryQuery.new project_id: @project_id,
                            secure_key: @secure_key,
                            code_name: code_name,
                            query_type: QUERY_TYPE_TAXONOMIES,
                            with_retry_policy: @with_retry_policy
        end

        # Return a single element of a content type
        #
        # * *Args*:
        #   - *content_type* (+string+) The code name of the content type containing the element
        #   - *element* (+string+) The code name of the desired element
        #
        # * *Returns*:
        #   - Kontent::Ai::Delivery::DeliveryQuery
        def element(content_type, element)
          DeliveryQuery.new project_id: @project_id,
                            secure_key: @secure_key,
                            code_name: element,
                            content_type: content_type,
                            query_type: QUERY_TYPE_ELEMENT,
                            with_retry_policy: @with_retry_policy
        end

        def languages
          DeliveryQuery.new project_id: @project_id,
                            secure_key: @secure_key,
                            query_type: QUERY_TYPE_LANGUAGES,
                            with_retry_policy: @with_retry_policy
        end
      end
    end
  end
end
