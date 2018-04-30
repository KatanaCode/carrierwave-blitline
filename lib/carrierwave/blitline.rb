module CarrierWave
  # Extend the behaviour of CarrierWave to support Blitline services
  module Blitline
    # frozen_string_literal: true

    # From the Blitline gem
    require "blitline"
    require "active_support/core_ext/module/attribute_accessors"
    require "active_support/core_ext/module/delegation"
    require "active_support/concern"
    require "carrierwave/blitline/version"
    require "carrierwave/blitline/image_version"
    require "carrierwave/blitline/function"
    require "carrierwave/blitline/image_version_function_presenter"

    extend ActiveSupport::Concern

    # Does the version name come at the start (carrierwave default) or at the
    # end of the filename
    RIP_VERSION_NAMES_AT_START = true

    # Blitline API version
    BLITLINE_VERSION = 1.21

    ##
    #
    UNIQUE_IDENTIFIER_TEMPLATE = "%{app_name}_%{rails_env}_%{token}".freeze

    # Extends the including class with ClassMethods, add an after_store callback
    # and includes ImageMagick if required.
    included do
      after :store, :rip_process_images
    end

    mattr_accessor :s3_bucket_name

    mattr_accessor :s3_bucket_region

    mattr_accessor :blitline_application_id


    # =============
    # = Delegates =
    # =============

    delegate :blitline_image_versions, to: :class

    delegate :process_via_blitline?,   to: :class

    # Send a request to Blitline to optimize the original file and create any
    # required versions.
    #
    #   This is called by an after_store macro and because Carrier creates virtual
    #   instancies for each version would be called 4 times for an image with three
    #   versions.
    #
    #   Because we only want to do this on completion we check all the versions
    #   have been called by testing it is OK to begin processing
    #
    #   A hash is created (job_hash) with Blitline's required commands and sent using the
    #   Blitline gem.
    #
    #  file - not used within the method, but required for the callback to function
    def rip_process_images(_file)
      return unless rip_can_begin_processing?
      Rails.logger.tagged("Blitline") { |l| l.debug(job_hash.to_json) }
      blitline_service.add_job_via_hash(job_hash)
      begin
        blitline_service.post_jobs
      rescue StandardError => e
        Rails.logger.tagged("Blitline") do |logger|
          logger.error format("ERROR: Blitline processing error for %<class>\n%<message>",
                              class: model.class.name, message: e.message)
        end
      end
    end

    # Returns a Hash of params posted off to Blitline API
    def job_hash
      {
        "application_id": Carrierwave,
        "src": url,
        "v": BLITLINE_VERSION,
        "functions": functions
      }.with_indifferent_access
    end

    # Returns a Hash for each function included in the Blitline API post
    def functions
      blitline_image_versions.map do |version|
        ImageVersionFunctionPresenter.new(version, self).to_hash
      end
    end

    # sends a request to Blitline to re-process themain image and all versions
    def optimize!
      rip_process_images(true) if process_via_blitline?
    end

    # Can we post the images to Blitline for processing?
    #   CarrierWave creates virtual Uploaders for each version of an image. These
    #   versions are processed before the original, so the only way to tell if the
    #   versions are all complete is to check the classname for the current call
    #   and if there is no '::' it is the original class.
    #
    # Returns a boolean
    def rip_can_begin_processing?
      process_via_blitline? && (!self.class.name.include? "::")
    end

    def filename
      "#{model.class.to_s.underscore}.#{file.extension}" if file
    end

    def unique_identifier
      @unique_identifier ||= begin
        UNIQUE_IDENTIFIER_TEMPLATE % { app_name: Rails.application.class.name,
                                       rails_env: Rails.env,
                                       token: SecureRandom.base64(10) }
      end
    end

    def file_name_for_version(version)
      file_name, file_type  = filename.split('.')
      name_components       = [version.name, file_name].compact
      name_components.reverse! unless RIP_VERSION_NAMES_AT_START
      file_namewith_version = name_components.join("_") + ".#{file_type}"
      File.join(store_dir, file_namewith_version).to_s
    end

    def params_for_function(function_name, *args)
      send("params_for_#{function_name}", *args)
    end

    def params_for_no_op(*_args)
      {}
    end

    def params_for_resize_to_fill(*args)
      args.flatten!
      { width: args.first, height: args.last }
    end

    def params_for_resize_to_fit(*args)
      args.flatten!
      { width: args.first, height: args.last }
    end


    private


    def blitline_service
      @blitline_service ||= ::Blitline.new
    end

    # Class methods to extend your Uploader classes
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
        @blitline_image_versions ||= [ImageVersion.new(nil)]
      end

      def process_via_blitline(value = true)
        @process_via_blitline = value
      end

      def process_via_blitline?
        defined?(@process_via_blitline) && @process_via_blitline == true
      end
    end
  end
end
