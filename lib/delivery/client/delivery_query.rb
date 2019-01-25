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
                  :secure_key,
                  :content_link_url_resolver

    # Setter for url, returns self for chaining
    # .url represents *manually* configured urls, otherwise final url is
    # generated in .execute and this will return nil
    def url(url = nil)
      @url = url unless url.nil?
      self
    end

    def initialize(config)
      self.project_id = config.fetch(:project_id)
      self.secure_key = config.fetch(:secure_key)
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
      @url = Delivery::UrlProvider.provide_url self if @url.nil?
      Delivery::UrlProvider.validate_url @url

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

    private

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
      if code_name.nil?
        Delivery::Responses::DeliveryItemListingResponse.new(
          JSON.parse(response),
          content_link_url_resolver
        )
      else
        Delivery::Responses::DeliveryItemResponse.new(
          JSON.parse(response)['item'],
          content_link_url_resolver
        )
      end
    end

    # Remove existing parameter from @params if key exists
    def remove_existing_param(key)
      params.delete_if { |i| i.key.eql? key }
    end
  end
end
