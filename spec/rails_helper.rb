# frozen_string_literal: true
# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
require File.expand_path('internal_test_hyrax/spec/rails_helper.rb', __dir__)
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('internal_test_hyrax/config/environment', __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'ammeter/init'
require 'factory_bot_rails'
require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'
require 'rails-controller-testing'
require 'selenium-webdriver'
require 'active_fedora/cleaner'
require 'noid/rails/rspec'
require 'webdrivers'
require 'webdrivers/chromedriver'
require 'webmock/rspec'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.

# Capybara config copied over from Hyrax
Capybara.register_driver :selenium_chrome_headless_sandboxless do |app|
  browser_options = ::Selenium::WebDriver::Chrome::Options.new
  browser_options.args << '--headless'
  browser_options.args << '--disable-gpu'
  browser_options.args << '--no-sandbox'
  # browser_options.args << '--disable-dev-shm-usage'
  # browser_options.args << '--disable-extensions'
  # client = Selenium::WebDriver::Remote::Http::Default.new
  # client.timeout = 90 # instead of the default 60
  # Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options, http_client: client)
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
end

Capybara.default_driver = :rack_test # This is a faster driver
Capybara.javascript_driver = :selenium_chrome_headless_sandboxless # This is slower
Capybara.default_max_wait_time = 10 # We may have a slow application, let's give it some time.

# FIXME: Pin to older version of chromedriver to avoid issue with clicking non-visible elements
Webdrivers::Chromedriver.required_version = '72.0.3626.69'

# Note: engine, not Rails.root context.
Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.before :suite do
    WebMock.disable_net_connect!(allow: ['localhost', '127.0.0.1', 'fedora', 'fedora-test', 'solr', 'solr-test', 'https://chromedriver.storage.googleapis.com'])
    Rails.application.routes.default_url_options[:host] = 'localhost:3000'
    Hyrax::Engine.routes.default_url_options[:host] = 'localhost:3000'
    Hyrax::Hirmeos::MetricsTracker.username = "UsernameTest"
    Hyrax::Hirmeos::MetricsTracker.password = "Password"
    Hyrax::Hirmeos::MetricsTracker.metrics_base_url = "https://metrics.example.com"
    Hyrax::Hirmeos::MetricsTracker.translation_base_url = "https://translator.example.com"
    Hyrax::Hirmeos::MetricsTracker.secret = "myt$stkey"
  end

  config.before do
    stub_request(:any, "#{Hyrax::Hirmeos::MetricsTracker.translation_base_url}/works")
    stub_request(:post, "#{Hyrax::Hirmeos::MetricsTracker.translation_base_url}/uris")
    stub_request(:get, Addressable::Template.new("#{Hyrax::Hirmeos::MetricsTracker.translation_base_url}/translate?uri=urn:uuid:{id}")).to_return(status: 200)
  end

  config.before(:suite) do
    ActiveFedora::Cleaner.clean!
  end

  config.after do
    ActiveFedora::Cleaner.clean!
  end

  include Noid::Rails::RSpec
  config.before(:suite) { disable_production_minter! }
  config.after(:suite)  { enable_production_minter! }

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
  config.include FactoryBot::Syntax::Methods
  config.include ::Rails::Controller::Testing::TemplateAssertions, type: :request
  config.include Features::SessionHelpers, type: :feature
end
