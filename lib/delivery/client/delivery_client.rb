require 'delivery/client/delivery_query'
require 'delivery/responses/delivery_item_listing_response'
require 'delivery/responses/delivery_item_response'
require 'json'

module Delivery
  QUERY_TYPE_TYPES = 'QUERY_TYPE_TYPES'.freeze
  QUERY_TYPE_ITEMS = 'QUERY_TYPE_ITEMS'.freeze
  
  # Executes requests against the Kentico Cloud Delivery API.
  class DeliveryClient
    attr_accessor :use_preview

    def initialize(config)
      @project_id = config.fetch(:project_id)
      @preview_key = config.fetch(:preview_key, nil)
      @secure_key = config.fetch(:secure_key, nil)
      @content_link_url_resolver = config.fetch(:content_link_url_resolver, nil)
      @inline_content_item_resolver = config.fetch(:inline_content_item_resolver, nil)
      self.use_preview = !@preview_key.nil?
    end

    def types
      DeliveryQuery.new project_id: @project_id,
                        secure_key: @secure_key,
                        query_type: QUERY_TYPE_TYPES
    end

    def type(code_name)
      DeliveryQuery.new project_id: @project_id,
                        secure_key: @secure_key,
                        code_name: code_name,
                        query_type: QUERY_TYPE_TYPES
    end

    def items(query_parameters = [])
      q = DeliveryQuery.new project_id: @project_id,
                            secure_key: @secure_key,
                            qp: query_parameters,
                            content_link_url_resolver: @content_link_url_resolver,
                            inline_content_item_resolver: @inline_content_item_resolver,
                            query_type: QUERY_TYPE_ITEMS
      q.use_preview = use_preview
      q.preview_key = @preview_key
      q
    end

    def item(code_name, query_parameters = [])
      q = DeliveryQuery.new project_id: @project_id,
                            secure_key: @secure_key,
                            code_name: code_name,
                            qp: query_parameters,
                            content_link_url_resolver: @content_link_url_resolver,
                            inline_content_item_resolver: @inline_content_item_resolver,
                            query_type: QUERY_TYPE_ITEMS
      q.use_preview = use_preview
      q.preview_key = @preview_key
      q
    end
  end
end
