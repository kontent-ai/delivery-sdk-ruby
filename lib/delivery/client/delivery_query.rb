require 'rest-client'

module Delivery
  # Responsible for translating query parameters into the
  # corresponding REST request to Kentico Cloud.
  class DeliveryQuery
    attr_accessor :use_preview,
                  :preview_key,
                  :project_id,
                  :code_name,
                  :params,
                  :content_link_url_resolver

    def initialize(config)
      self.project_id = config.fetch(:project_id)
      self.code_name = config.fetch(:code_name, nil)
      self.content_link_url_resolver = config.fetch(:content_link_url_resolver, nil)
      self.params = if config.fetch(:qp).is_a? Array
                      config.fetch(:qp)
                    else
                      [config.fetch(:qp)]
                    end
      raise ArgumentError, 'Only filters may be passed in the .item or .items methods.' unless @params.all? { |p| p.is_a? Delivery::QueryParameters::Filter }
    end

    def execute
      @url = Delivery::UrlProvider.provide_url self
      Delivery::UrlProvider.validate_url @url

      begin
        resp = execute_rest
      rescue RestClient::Unauthorized, RestClient::Forbidden => err
        yield err.response
      else
        yield make_response resp
      end
    end

    def execute_rest
      if use_preview
        RestClient.get @url, Authorization: 'Bearer ' + preview_key
      else
        RestClient.get @url
      end
    end

    def make_response(response)
      if code_name.nil?
        DeliveryItemListingResponse.new(JSON.parse(response), content_link_url_resolver)
      else
        DeliveryItemResponse.new(JSON.parse(response)['item'], content_link_url_resolver)
      end
    end

    # Remove existing parameter from @params if key exists
    def remove_existing_param(key)
      params.delete_if { |i| i.key.eql? key }
    end

    def order_by(value, sort = '[asc]')
      remove_existing_param 'order'
      params << Delivery::QueryParameters::ParameterBase.new('order', '', value + sort)
      self
    end

    def skip(value)
      remove_existing_param 'skip'
      params << Delivery::QueryParameters::ParameterBase.new('skip', '', value)
      self
    end

    def language(value)
      remove_existing_param 'language'
      params << Delivery::QueryParameters::ParameterBase.new('language', '', value)
    end

    def limit(value)
      remove_existing_param 'limit'
      params << Delivery::QueryParameters::ParameterBase.new('limit', '', value)
      self
    end

    def elements(value)
      remove_existing_param 'elements'
      params << Delivery::QueryParameters::ParameterBase.new('elements', '', value)
      self
    end

    def depth(value)
      remove_existing_param 'depth'
      params << Delivery::QueryParameters::ParameterBase.new('depth', '', value)
      self
    end
  end
end
