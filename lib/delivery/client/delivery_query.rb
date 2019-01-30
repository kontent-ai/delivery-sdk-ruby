require 'rest-client'
require 'delivery/client/url_provider'

module Delivery
  # Responsible for translating query parameters into the
  # corresponding REST request to Kentico Cloud.
  class DeliveryQuery
    attr_accessor :use_preview,
                  :preview_key,
                  :project_id,
                  :code_name,
                  :params,
                  :secure_key,
                  :content_link_url_resolver,
                  :query_type

    # Setter for url, returns self for chaining
    # .url represents *manually* configured urls, otherwise final url is
    # generated in .execute and this will return nil
    def url(url = nil)
      @url = url unless url.nil?
      self
    end

    def initialize(config)
      # Map each hash value to attr with corresponding key
      # from https://stackoverflow.com/a/2681014/5656214
      config.each do |k, v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
      return if config.fetch(:qp, nil).nil?

      # Query parameters were passed, parse and validate
      validate_params config.fetch(:qp)
    end

    def execute
      provide_url
      begin
        resp = execute_rest
      rescue RestClient::ExceptionWithResponse => err
        yield Delivery::Responses::ResponseBase.new err.http_code, err.response
      rescue RestClient::SSLCertificateNotVerified => err
        yield Delivery::Responses::ResponseBase.new 500, err
      rescue SocketError => err
        yield Delivery::Responses::ResponseBase.new 500, err.message
      else
        yield make_response resp
      end
    end

    def with_link_resolver(resolver)
      self.content_link_url_resolver = resolver
      self
    end

    def order_by(value, sort = '[asc]')
      set_param('order', value + sort)
      self
    end

    def skip(value)
      set_param('skip', value)
      self
    end

    def language(value)
      set_param('language', value)
    end

    def limit(value)
      set_param('limit', value)
      self
    end

    def elements(value)
      set_param('elements', value)
      self
    end

    def depth(value)
      set_param('depth', value)
      self
    end

    private

    def provide_url
      @url = Delivery::UrlProvider.provide_url self if @url.nil?
      Delivery::UrlProvider.validate_url @url
    end

    def validate_params(query_parameters)
      self.params = if query_parameters.is_a? Array
                      query_parameters
                    else
                      [query_parameters]
                    end
      params.each do |p|
        unless p.is_a? Delivery::QueryParameters::Filter
          raise ArgumentError, 'Only filters may be passed in the .item or .items methods.'
        end
      end
    end

    def set_param(key, value)
      self.params = [] if params.nil?
      remove_existing_param key
      params << Delivery::QueryParameters::ParameterBase.new(key, '', value)
    end

    def execute_rest
      if use_preview
        RestClient.get @url, Authorization: 'Bearer ' + preview_key
      else
        if secure_key.nil?
          RestClient.get @url
        else
          RestClient.get @url, Authorization: 'Bearer ' + secure_key
        end
      end
    end

    def make_response(response)
      case query_type
      when Delivery::QUERY_TYPE_ITEMS
        if code_name.nil?
          Delivery::Responses::DeliveryItemListingResponse.new(
            JSON.parse(response),
            content_link_url_resolver
          )
        else
          Delivery::Responses::DeliveryItemResponse.new(
            JSON.parse(response),
            content_link_url_resolver
          )
        end
      when Delivery::QUERY_TYPE_TYPES
        if code_name.nil?
          Delivery::Responses::DeliveryTypeListingResponse.new JSON.parse(response)
        else
          Delivery::Responses::DeliveryTypeResponse.new JSON.parse(response)
        end
      end
    end

    # Remove existing parameter from @params if key exists
    def remove_existing_param(key)
      params.delete_if { |i| i.key.eql? key } unless params.nil?
    end
  end
end
