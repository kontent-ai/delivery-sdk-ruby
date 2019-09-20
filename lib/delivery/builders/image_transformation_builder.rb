require 'delivery/query_parameters/query_string'

module Kentico
  module Kontent
    module Delivery
      module Builders
        # Provides methods for manipulating the URL of an asset to adjust the image's
        # size, cropping behavior, background color, output format, and quality.
        #
        # See https://developer.kenticocloud.com/v1/reference#image-transformation and
        # https://github.com/Kentico/kontent-delivery-sdk-ruby#image-transformation.
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
          BOOLEAN_PARAM = 'The parameter must be a boolean, 0, or 1.'.freeze

          # Constructor. Generally, you obtain an +AssetURL+ object by calling
          # Kentico::Kontent::Delivery::Builders::ImageTransformationBuilder.transform
          # instead of using this constructor.
          def initialize(url)
            @url = url
            @query_string = Kentico::Kontent::Delivery::QueryParameters::QueryString.new
          end

          # Applies all transformation options to the asset URL.
          #
          # * *Returns*:
          #   - +string+ The full URL to the asset with all query string parameters set
          def url
            @url + @query_string.to_s
          end

          # Sets the width of the image
          #
          # * *Args*:
          #   - *width*
          #     - +integer+ Width in pixels, between 1 and 8192.
          #     - +float+ Width in percentage, between 0 and 1.
          #
          # * *Returns*:
          #   - +self+
          def with_width(width)
            @query_string.set_param 'w', width
            self
          end

          # Sets the height of the image
          #
          # * *Args*:
          #   - *height*
          #     - +integer+ Height in pixels, between 1 and 8192.
          #     - +float+ Height in percentage, between 0 and 1.
          #
          # * *Returns* :
          #   - +self+
          def with_height(height)
            @query_string.set_param 'h', height
            self
          end

          # Sets the device pixel ratio. Either width or height
          # (or both) must be set.
          #
          # * *Args*:
          #   - *dpr* (+float+) Pixel ratio between 0 and 5.
          #
          # * *Returns*:
          #   - +self+
          def with_pixel_ratio(dpr)
            @query_string.set_param 'dpr', dpr
            self
          end

          # Defines how the image is constrained while resizing. Either width
          # or height (or both) must be set.
          #
          # * *Args*:
          #   - *fit* (+string+) Use constants from Kentico::Kontent::Delivery::Builders::ImageTransformationBuilder
          #
          # * *Returns*:
          #   - +self+
          def with_fit_mode(fit)
            @query_string.set_param 'fit', fit
            self
          end

          # Selects a region of the image to perform transformations on.
          # Setting this will remove focal point cropping from the image,
          # as the two options are incompatible.
          #
          # * *Args*:
          #   - *x*
          #     - +integer+ The left border of the rect in pixels
          #     - +float+ The left border of the rect as a percentage between 0 and 1
          #   - *y*
          #     - +integer+ The top border of the rect in pixels
          #     - +float+ The top border of the rect as a percentage between 0 and 1
          #   - *width*
          #     - +integer+ The width of the rect in pixels
          #     - +float+ The width of the rect as a percentage between 0 and 1
          #   - *height*
          #     - +integer+ The height of the rect in pixels
          #     - +float+ The height of the rect as a percentage between 0 and 1
          #
          # * *Returns*:
          #   - +self+
          def with_rect(x, y, width, height)
            @query_string.remove_param 'fp-x'
            @query_string.remove_param 'fp-y'
            @query_string.remove_param 'fp-z'
            @query_string.remove_param 'crop'
            @query_string.set_param 'rect', "#{x},#{y},#{width},#{height}"
            self
          end

          # Sets the point of interest when cropping the image.
          # Setting this will remove the source rectangle region,
          # as the two options are incompatible. It also automatically sets the
          # crop to "focalpoint" and fit to "crop"
          #
          # * *Args*:
          #   - *x* (+float+) Percentage of the image's width between 0 and 1
          #   - *y* (+float+) Percentage of the image's height between 0 and 1
          #   - *z* (+integer+) Amount of zoom to apply. A value of 1 is the default zoom, and each step represents 100% additional zoom.
          #
          # * *Returns*:
          #   - +self+
          def with_focal_point(x, y, z)
            raise ArgumentError, INVALID_PARAMS unless valid_dims?(x, y, z)

            @query_string.remove_param 'rect'
            @query_string.set_param 'fp-x', x
            @query_string.set_param 'fp-y', y
            @query_string.set_param 'fp-z', z
            @query_string.set_param 'fit', ImageTransformationBuilder::FIT_MODE_CROP
            @query_string.set_param 'crop', 'focalpoint'
            self
          end

          # Sets the background color of any transparent areas of the image.
          #
          # * *Args*:
          #   - *color* (+string+) A valid 3, 4, 6, or 8 digit hexadecimal color, without the # symbol
          #
          # * *Returns*:
          #   - +self+
          def with_background_color(color)
            @query_string.set_param 'bg', color
            self
          end

          # Sets the output format of the request for the image.
          #
          # * *Args*:
          #   - *format* (+string+) Use constants from Kentico::Kontent::Delivery::Builders::ImageTransformationBuilder
          #
          # * *Returns*:
          #   - +self+
          def with_output_format(format)
            @query_string.set_param 'fm', format
            self
          end

          # Configure the amount of compression for lossy file formats. Lower quality
          # images will have a smaller file size. Only affects *jpg*, *pjpg*, and
          # *webp* files.
          #
          # When no quality is specified for an image transformation, the default
          # value of 85 is used.
          #
          # * *Args*:
          #   - *quality* (+integer+) The quality of the image between 1 and 100
          #
          # * *Returns*:
          #   - +self+
          #
          # * *Raises*:
          #   - +ArgumentError+ if +quality+ is not between 1 and 100 inclusive
          def with_quality(quality)
            raise ArgumentError, ONE_TO_100 unless quality.to_i >= 1 && quality.to_i <= 100

            @query_string.set_param 'q', quality
            self
          end

          # Sets the lossless parameter. If +true+, automatically sets the format
          # to WebP.
          #
          # * *Args*:
          #   - *lossless*
          #     - +integer+ Either 1 or 0
          #     - +bool+ Either +true+ or +false+
          #     - +string+ Either 'true' or 'false'
          #
          # * *Returns*:
          #   - +self+
          #
          # * *Raises*:
          #   - +ArgumentError+ if +lossless+ cannot be parsed as a boolean
          def with_lossless(lossless)
            lossless = lossless.to_s.downcase
            raise ArgumentError, BOOLEAN_PARAM unless bool? lossless

            @query_string.set_param 'lossless', lossless
            @query_string.set_param 'fm', Kentico::Kontent::Delivery::Builders::ImageTransformationBuilder::FORMAT_WEBP if %w[true 1].include? lossless
            self
          end

          # Enables or disables automatic format selection. If enabled, it will
          # override the format parameter and deliver WebP instead. If the browser
          # does not support WebP, the value of the format parameter will be used.
          #
          # * *Args*:
          #   - *auto*
          #     - +integer+ Either 1 or 0
          #     - +bool+ Either +true+ or +false+
          #     - +string+ Either 'true' or 'false'
          #
          # * *Returns*:
          #   - +self+
          #
          # * *Raises*:
          #   - +ArgumentError+ if +auto+ cannot be parsed as a boolean
          def with_auto_format_selection(auto)
            auto = auto.to_s.downcase
            raise ArgumentError, BOOLEAN_PARAM unless bool? auto

            if %w[true 1].include? auto
              @query_string.set_param 'auto', 'format'
            else
              @query_string.remove_param 'auto'
            end
            self
          end

          private

          def valid_dims?(x, y, z)
            (x.to_f >= 0.0 && x.to_f <= 1.0) &&
              (y.to_f >= 0.0 && y.to_f <= 1.0) &&
              (z.to_i >= 1)
          end

          def bool?(value)
            %w[true false 0 1].include? value
          end
        end
      end
    end
  end
end
