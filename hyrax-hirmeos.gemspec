# frozen_string_literal: true
$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "hyrax/hirmeos/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "hyrax-hirmeos"
  spec.version     = Hyrax::Hirmeos::VERSION
  spec.authors     = ["BertZZ"]
  spec.email       = ["bertie.wooles@gmail.com", "tech@ubiquitypress.com"]
  spec.homepage    = ""
  spec.summary     = "A Hyrax plugin to allow collection and display of HIRMEOS metrics"
  spec.description = "Description of Hyrax::Hirmeos."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 5.2.4", ">= 5.2.4.3"
  spec.add_dependency "hyrax", "~> 2.8"

  spec.add_development_dependency "bixby"
  spec.add_development_dependency 'capybara'
  spec.add_development_dependency 'chromedriver-helper', '~> 2.1'
  spec.add_development_dependency "factory_bot_rails"
  spec.add_development_dependency 'rspec_junit_formatter'
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency('simplecov', '0.17.1', '< 0.18')
  spec.add_development_dependency 'webdrivers', '~> 4.0'
  spec.add_development_dependency 'webmock'
end
