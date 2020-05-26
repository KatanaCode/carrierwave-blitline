# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'carrierwave/blitline/version'

Gem::Specification.new do |spec|
  spec.name          = "carrierwave-blitline"
  spec.version       = CarrierWave::Blitline::VERSION
  spec.authors       = ["Bodacious"]
  spec.email         = ["team@katanacode.com"]

  spec.summary       = %q{Integrates Blitline image processing with Carrierwave}
  spec.description   = %q{Integrates the carrierwave gem with Blitline image API. (Still under development)}
  spec.homepage      = "https://github.com/KatanaCode/carrierwave-blitline"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "blitline", "~> 2.8"
  spec.add_dependency "activesupport", ">= 3.0.0", "<= 5.2.4.3"
  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec_junit_formatter"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "rubocop"
end
