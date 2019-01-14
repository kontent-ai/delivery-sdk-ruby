require 'rest-client'

module Delivery
  # Responsible for translating query parameters into the
  # corresponding REST request to Kentico Cloud.
  class DeliveryQuery
    URL_MAX_LENGTH = 65_519
    URL_TEMPLATE_BASE = 'https://deliver.kenticocloud.com/%s'.freeze
    URL_TEMPLATE_ITEM = '/items/%s'.freeze
    URL_TEMPLATE_ITEMS = '/items'.freeze
    URL_TEMPLATE_TYPE = '/types/%s'.freeze
    URL_TEMPLATE_TYPES = '/types'.freeze
    URL_TEMPLATE_ELEMENTS = '/types/%s/elements/%s'.freeze
    URL_TEMPLATE_TAXONOMY = '/taxonomies/%s'.freeze
    URL_TEMPLATE_TAXONOMIES = '/taxonomies'.freeze
    MSG_LONG_QUERY = 'The request url is too long. Split your query into multiple calls.'.freeze

    def initialize(config)
      @project_id = config.fetch(:project_id)
      @code_name = config.fetch(:code_name, nil)
      @params = if config.fetch(:qp).is_a? Array
                  config.fetch(:qp)
                else
                  [config.fetch(:qp)]
                end
      raise ArgumentError, 'Only filters may be passed in the .item or .items methods.' unless @params.all? { |p| p.is_a? Delivery::QueryParameters::Filter}
    end

    def execute
      url = provide_url
      raise UriFormatException, MSG_LONG_QUERY if url.length > URL_MAX_LENGTH

      begin
        resp = RestClient.get(url)
      rescue RestClient::Unauthorized, RestClient::Forbidden => err
        yield err.response
      else
        if @code_name.nil?
          yield DeliveryItemListingResponse.new(JSON.parse(resp))
        else
          yield DeliveryItemResponse.new(JSON.parse(resp)['item'])
        end
      end
    end

    def provide_url
      query = format(URL_TEMPLATE_BASE, @project_id)
      query += (@code_name.nil? ? URL_TEMPLATE_ITEMS : format(URL_TEMPLATE_ITEM, @code_name))
      return query if @params.length.zero?

      querystring = []
      @params.each { |n| querystring << n.provide_query_string_parameter }
      query + '?' + querystring.join('&')
    end

    # Remove existing parameter from @params if key exists
    def remove_existing_param(key)
      @params.delete_if { |i| i.key.eql? key }
    end

    def order_by(value, sort = '[asc]')
      remove_existing_param 'order'
      @params << Delivery::QueryParameters::ParameterBase.new('order', '', value + sort)
      self
    end

    def skip(value)
      remove_existing_param 'skip'
      @params << Delivery::QueryParameters::ParameterBase.new('skip', '', value)
      self
    end

    def limit(value)
      remove_existing_param 'limit'
      @params << Delivery::QueryParameters::ParameterBase.new('limit', '', value)
      self
    end

    def elements(value)
      remove_existing_param 'elements'
      @params << Delivery::QueryParameters::ParameterBase.new('elements', '', value)
      self
    end

    def depth(value)
      remove_existing_param 'depth'
      @params << Delivery::QueryParameters::ParameterBase.new('depth', '', value)
      self
    end
  end
end
