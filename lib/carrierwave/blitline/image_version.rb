module CarrierWave
  module Blitline
    # An instance of an ImageVersion for Blitline API.
    #
    #   When the process() version is called in an Uploader class, we store the version
    #     name, and the block to create that version as an ImageVersion
    #
    #   So, a 'small' image version that's resized to fit 200x200 looks like:
    #
    #     ImageVersion.new("small") do
    #       process :resize_to_fit => [200, 200]
    #     end
    #
    #  NOTE: We need a 'default' image version too. This is created automatically, and
    #    the name for the version is 'nil'.
    class ImageVersion

      attr_accessor :primary_function

      attr_accessor :secondary_functions

      attr_reader :name

      def initialize(name = nil, &block)
        @name                = name
        @primary_function    = nil
        @secondary_functions = []
        instance_exec(&block) if block_given?
      end

      # Hijacks the process() method that's called within a CarrierWave uploader.
      #
      # Example:
      #
      #   version :thumb do
      #     process :crop            => [10, 10, 200, 200]
      #     process :process_to_fill => [500, 500]
      #   end
      #
      #  This stores the crop function as the "primary" function, and the process_to_fill
      #    function as a "secondary" function.
      def process(function_hash)
        function_hash   = { function_hash => nil } unless function_hash.is_a?(Hash)
        function_name   = function_hash.keys.first
        function_params = function_hash.values.first
        function = Function.new(function_name, function_params)
        if primary_function.nil?
          self.primary_function    = function
        else
          self.secondary_functions << function
        end
      end

      # Returns a String of the name of the primary function for this version
      #   (default: "no_op")
      def primary_function_name
        primary_function.nil? ? "no_op" : primary_function.name
      end

      # Returns a Hash of the params of the primary function for this
      #   version (default: {})
      def primary_function_params
        primary_function.nil? ? {} : primary_function.params
      end

    end
  end
end
