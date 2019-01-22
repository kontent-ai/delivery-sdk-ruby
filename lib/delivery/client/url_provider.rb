module Delivery
  # Generates the URL required for Delivery REST API
  class UrlProvider
    URL_TEMPLATE_BASE = 'https://deliver.kenticocloud.com/%s'.freeze
    URL_TEMPLATE_PREVIEW = 'https://preview-deliver.kenticocloud.com/%s'.freeze
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
      def provide_url(query)
        url = provide_base_url(query.project_id, query.use_preview)
        url +=
          if query.code_name.nil?
            URL_TEMPLATE_ITEMS
          else
            format(URL_TEMPLATE_ITEM, query.code_name)
          end

        # Map each parameter to the result of a method and separate with &
        url + '?' + query.params.map(&:provide_query_string_parameter).join('&')
      end

      def validate_url(url)
        raise UriFormatException, MSG_LONG_QUERY if url.length > URL_MAX_LENGTH
      end

      def provide_base_url(project_id, use_preview)
        if use_preview
          format(URL_TEMPLATE_PREVIEW, project_id)
        else
          format(URL_TEMPLATE_BASE, project_id)
        end
      end
    end
  end
end
