# Carrierwave::Blitline

This gem is still under construction but it basically works in its current form.

## Installation

Install it with these other Carrierwave gems:

    gem "carrierwave"

    gem "carrierwave-aws"

    gem "carrierwave-blitline"

Then execute

     $ bundle install

Add this to your Carrierwave Uploader files:

    class ImageUploader < CarrierWave::Uploader::Base

      # NOTE: We're using MiniMagick here...
      include CarrierWave::MiniMagick

      require "carrierwave/blitline"
      include CarrierWave::Blitline


      # This macro lets your uploader know you're using Carrierwave
      process_via_blitline


      # other stuff ...

    end

## CONFIGURE

### Your Carrierwave setup should be something like this

    CarrierWave.configure do |config|

      if Rails.env.test?
        config.storage           = :file
        config.enable_processing = false
        config.asset_host        = 'http://test.host'

      else
        config.aws_credentials = {
          :access_key_id     => ENV["AWS_ACCESS_KEY"],
          :secret_access_key => ENV["AWS_SECRET_ACCESS_KEY"],
          :region            => ENV["S3_BUCKET_REGION"]
        }
        config.storage            :aws
        config.aws_bucket                       = ENV["S3_BUCKET_NAME"]
        config.aws_acl                          = 'public-read'
        config.aws_attributes                   = {
          expires: 1.week.from_now.httpdate, cache_control: 'max-age=315576000' }

        config.asset_host = "https://%s" % ENV["ASSET_HOST"]
        config.enable_processing                = true
        config.aws_authenticated_url_expiration = 60 * 60 * 24 * 7
      end

    end

### ENV Variables
The following env variables must be set for this to work properly.

    ENV["BLITLINE_APPLICATION_ID"]
    ENV["S3_BUCKET_NAME"]
    ENV["S3_BUCKET_REGION"]

## Usage

Define your carrierwave versions as you normally would.

Basic functions (`resize_to_fit`, `resize_to_fill`, etc.) are dealt with automagically.

For other functions, you need to write two methods in your uploader: 1) The local processing method, 2) the params for Blitline. For example

    # Images will be cropped, and then resized to fill
    version :cropped do
      process :crop
      process :resize_to_fill => [200, 200]
    end

    # Use this when processing locally
    def crop
      manipulate! do |img|
        img = img.crop "#{model.photo_crop_x}x#{model.photo_crop_y}+#{model.photo_crop_width}+#{model.photo_crop_height}"
        img
      end
    end

    # Use this when processing on Blitline
    def params_for_crop(*)
      return {
        x: model.photo_crop_x,
        y: model.photo_crop_y,
        width: model.photo_crop_width,
        height: model.photo_crop_height
      }
    end


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/katanacode/carrierwave-blitline.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Created by

[Katana — web developers based in Edinburgh, Scotland](https://katanacode.com/)