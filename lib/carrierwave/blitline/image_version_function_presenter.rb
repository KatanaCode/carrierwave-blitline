module CarrierWave
  module Blitline

    # A presenter class for converting an image version to a JSON param for the Blitline
    #   API.
    class ImageVersionFunctionPresenter


      ##
      # The ImageVersion we're presenting
      attr_accessor :version

      ##
      # The Uploader instance we're processing an image for.
      attr_accessor :uploader


      # =============
      # = Delegates =
      # =============

      delegate :params_for_function, to: :uploader

      delegate :file_name_for_version, to: :uploader

      delegate :unique_identifier, to: :uploader

      delegate :primary_function_name, to: :version

      delegate :primary_function_params, to: :version

      delegate :secondary_functions, to: :version


      # Creates a new presenter.
      #
      # version  - The ImageVersion to use
      # uploader - The CarrierWave uploader instance
      def initialize(version, uploader)
        @version  = version
        @uploader = uploader
      end

      # The Hash to be converted to JSON for the Blitline API
      def to_hash
        {
          "name":   primary_function_name,
          "params": params_for_function(primary_function_name, primary_function_params),
          "save": {
            "image_identifier": unique_identifier,
            "s3_destination": {
              "bucket": {
                "name":     ENV["S3_BUCKET_NAME"],
                "location": ENV["S3_BUCKET_REGION"],
              },
              "key": file_name_for_version(version)
            }
          },
          "functions": secondary_functions.map { |function|
            {
              "name": function.name,
              "params": params_for_function(function.name,function.params),
              "save": {
                "image_identifier": unique_identifier,
                "s3_destination": {
                  "bucket": {
                    "name":     ENV["S3_BUCKET_NAME"],
                    "location": ENV["S3_BUCKET_REGION"],
                  },
                  "key": file_name_for_version(version)
                }
              }
            }
          }
        }
      end

    end

  end

end
