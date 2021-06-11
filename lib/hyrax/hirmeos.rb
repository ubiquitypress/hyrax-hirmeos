# frozen_string_literal: true
require "hyrax/hirmeos/engine"

module Hyrax
  module Hirmeos
    def self.configured?
      [Hyrax::Hirmeos::MetricsTracker.username,
       Hyrax::Hirmeos::MetricsTracker.password,
       Hyrax::Hirmeos::MetricsTracker.metrics_base_url,
       Hyrax::Hirmeos::MetricsTracker.translation_base_url,
       Hyrax::Hirmeos::MetricsTracker.secret].all?(&:present?)
    end
  end
end
