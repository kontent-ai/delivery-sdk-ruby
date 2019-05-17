require 'dotenv/load'
require 'pathname'
require 'cgi'

module KenticoCloud
  module Delivery
    module Tests
      class FakeResponder
        PROJECT_ID = ENV['PROJECT_ID']
        IS_SECURE = ENV['TEST_SECURE_API_ENABLED']
        SECURE_KEY = ENV['SECURE_KEY']
        PREVIEW_KEY = ENV['PREVIEW_KEY']
        BASE_URL = "https://deliver.kenticocloud.com/#{PROJECT_ID}".freeze
        PREVIEW_URL = "https://preview-deliver.kenticocloud.com/#{PROJECT_ID}".freeze

        class << self
          def get_response(query, url, headers)
            @query = query
            if IS_SECURE && !(
               headers['Authorization'] == "Bearer #{SECURE_KEY}" ||
               headers['Authorization'] == "Bearer #{PREVIEW_KEY}"
             )
              return respond_401
            end

            url =
              if @query.should_preview
                url[PREVIEW_URL.length...url.length]
              else
                url[BASE_URL.length...url.length]
              end

            qs = url.contains('?') ? url.split('?')[1] : nil
            return respond_filtering qs unless qs.nil? # e.g. /items/about_us?skip=0&limit=5

            respond_generic url # Didn't match other clauses, so response should be located in corresponding filepath
          end

          def respond_generic(url)
            path = Pathname.new(File.dirname(__FILE__) + "/generic#{url}.json")
            path.read if path.exist?
          end

          def respond_filtering(query)
            path =
              case CGI.unescape query
              when 'skip=0&limit=5'
                Pathname.new(File.dirname(__FILE__) + '/filtering/pagination_about_us.json')
              when 'elements.price[gt]=20'
                Pathname.new(File.dirname(__FILE__) + '/filtering/items_gt.json')
              when 'elements.price[gt]=20&system.type=grinder'
                Pathname.new(File.dirname(__FILE__) + '/filtering/multiple.json')
              end
            path.read unless path.nil? && !path.exist?
          end

          def respond_401
            path = Pathname.new(File.dirname(__FILE__) + '/401.json')
            KenticoCloud::Delivery::Responses::ResponseBase.new 401, '', path.read if path.exist?
          end
        end
      end
    end
  end
end
