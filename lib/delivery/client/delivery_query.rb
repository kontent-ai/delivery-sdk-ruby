require 'rest-client'

module Delivery
  # Responsible for translating query parameters into the
  # corresponding REST request to Kentico Cloud.
  class DeliveryQuery
    attr_accessor :code_name
    attr_accessor :params

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

    def initialize(project_id)
      @project_id = project_id
    end

    def execute
      url = provide_url
      raise UriFormatException, MSG_LONG_QUERY if url.length > URL_MAX_LENGTH

      RestClient.get url
    end

    def provide_url
      query = format(URL_TEMPLATE_BASE, @project_id)
      query += (code_name.nil? ? URL_TEMPLATE_ITEMS : format(URL_TEMPLATE_ITEM, code_name))
      return query if params.nil?

      querystring = []
      params.each { |n| querystring << n.provide_query_string_parameter }
      query + '?' + querystring.join('&')
    end
  end
end
