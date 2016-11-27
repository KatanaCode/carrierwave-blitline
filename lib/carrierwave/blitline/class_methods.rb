# Class methods to be included in Blitline module
module CarrierWave
  module Blitline

    module ClassMethods

      def version(name, &block)
        blitline_image_versions << ImageVersion.new(name, &block)
        # If process_via_blitline? is true, we still want to register the version with
        #  the Uploader, but we don't want to define the conversions.
        if process_via_blitline?
          super(name) {}
        else
          super(name, &block)
        end
      end

      def blitline_image_versions
        @blitline_versions ||= [ImageVersion.new(nil)]
      end

      def process_via_blitline(value = true)
        @@process_via_blitline = value
      end

      def process_via_blitline?
        defined?(@@process_via_blitline) && @@process_via_blitline == true
      end

    end
  end

end
