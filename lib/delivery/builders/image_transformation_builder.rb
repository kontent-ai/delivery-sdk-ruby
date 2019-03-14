require 'delivery/query_parameters/query_string'

module KenticoCloud
  module Delivery
    module Builders
      class ImageTransformationBuilder
        FIT_MODE_CLIP = 'clip'.freeze
        FIT_MODE_SCALE = 'scale'.freeze
        FIT_MODE_CROP = 'crop'.freeze
        FORMAT_GIF = 'gif'.freeze
        FORMAT_PNG = 'png'.freeze
        FORMAT_PNG8 = 'png8'.freeze
        FORMAT_JPG = 'jpg'.freeze
        FORMAT_PJPG = 'pjpg'.freeze
        FORMAT_WEBP = 'webp'.freeze

        class << self
          def transform(url)
            AssetURL.new url
          end
        end
      end

      class AssetURL
        INVALID_PARAMS = 'One or more of the parameters is invalid. '\
        'See https://developer.kenticocloud.com/v1/reference#focal-point-crop'\
        'for more information.'.freeze
        ONE_TO_100 = 'Quality parameter must be between 1 and 100.'.freeze
        BOOLEAN_PARAM = 'The lossless parameter must be "true," "false," '\
        '1, or 0.'.freeze

        def initialize(url)
          @url = url
          @query_string = KenticoCloud::Delivery::QueryParameters::QueryString.new
        end

        def url
          @url + @query_string.to_s
        end

        def with_width(width)
          @query_string.set_param 'w', width
          self
        end

        def with_height(height)
          @query_string.set_param 'h', height
          self
        end

        def with_pixel_ratio(dpr)
          @query_string.set_param 'dpr', dpr
          self
        end

        def with_fit_mode(fit)
          @query_string.set_param 'fit', fit
          self
        end

        # Setting this will remove focal point cropping from the image,
        # as the two options are incompatible.
        # @param x
        # @param y
        # @param width
        # @param height
        def with_rect(x, y, width, height)
          @query_string.remove_param 'fp-x'
          @query_string.remove_param 'fp-y'
          @query_string.remove_param 'fp-z'
          @query_string.remove_param 'crop', 'focalpoint'
          @query_string.set_param 'rect', "#{x},#{y},#{width},#{height}"
          self
        end

        # Setting this will remove the source rectangle region,
        # as the two options are incompatible.
        def with_focal_point(x, y, z)
          raise ArgumentError, INVALID_PARAMS unless valid_dims?(x, y, z)

          @query_string.remove_param 'rect'
          @query_string.set_param 'fp-x', x
          @query_string.set_param 'fp-y', y
          @query_string.set_param 'fp-z', z
          @query_string.set_param 'crop', 'focalpoint'
          self
        end

        def valid_dims?(x, y, z)
          (x.to_f >= 0.0 && x.to_f <= 1.0) &&
            (y.to_f >= 0.0 && y.to_f <= 1.0) &&
            (z.to_i >= 1)
        end

        # Sets the background color.
        # @param [String] color a valid 3, 4, 6, or 8 digit hexadecimal color, without the # symbol
        def with_background_color(color)
          @query_string.set_param 'bg', color
          self
        end

        def with_output_format(format)
          @query_string.set_param 'fm', format
          self
        end

        def with_quality(quality)
          raise ArgumentError, ONE_TO_100 unless quality.to_i >= 1 && quality.to_i <= 100

          @query_string.set_param 'q', quality
          self
        end

        # Sets lossless to true or false. If true, automatically sets the format to WebP
        def with_lossless(lossless)
          lossless = lossless.to_s.downcase
          raise ArgumentError, BOOLEAN_PARAM unless bool? lossless

          @query_string.set_param 'lossless', lossless
          @query_string.set_param 'fm', KenticoCloud::Delivery::Builders::ImageTransformationBuilder::FORMAT_WEBP if %w[true 1].include? lossless
          self
        end

        def bool?(value)
          (value == 'true') ||
            (value == 'false') ||
            (value == '0') ||
            (value == '1')
        end

        def with_auto_format_selection(auto)
          auto = auto.to_s.downcase
          if %w[true 1].include? auto
            @query_string.set_param 'auto', 'format'
          else
            @query_string.remove_param 'auto'
          end
          self
        end
      end
    end
  end
end
