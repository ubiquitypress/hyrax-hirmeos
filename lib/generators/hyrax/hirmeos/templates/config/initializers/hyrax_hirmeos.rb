# frozen_string_literal: true
## Set a default host and protocal for urls
# Rails.application.routes.default_url_options[:host] = 'localhost:3000'
# Hyrax::Engine.routes.default_url_options[:host] = 'localhost:3000'

## For the metrics Widget to display your metrics, the links must be sent as https
# Rails.application.routes.default_url_options[:protocol] = 'https'
# Hyrax::Engine.routes.default_url_options[:protocol] = 'https'

require 'hyrax/hirmeos/metrics_tracker'

Hyrax::Hirmeos::MetricsTracker.username = "Username"
Hyrax::Hirmeos::MetricsTracker.password = "secure_password"
Hyrax::Hirmeos::MetricsTracker.metrics_base_url = "https://metrics_base_url"
Hyrax::Hirmeos::MetricsTracker.translation_base_url = "https://translations_base_url"
Hyrax::Hirmeos::MetricsTracker.secret = ENV['HIRMEOS_TRANSLATOR_KEY']
Hyrax::Hirmeos::MetricsTracker.work_factory = Hyrax::Hirmeos::WorkFactory

Hyrax.config.callback.set(:after_create_fileset) do |file_set, user|
  FileSetAttachedEventJob.perform_later(file_set, user)
  Hyrax::Hirmeos::HirmeosFileUpdaterJob.perform_later(file_set)
end
