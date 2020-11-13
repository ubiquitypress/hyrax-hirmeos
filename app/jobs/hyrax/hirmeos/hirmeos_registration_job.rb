# frozen_string_literal: true
module Hyrax
  module Hirmeos
    class HirmeosRegistrationJob < ApplicationJob
      def perform(resource)
        Hyrax::Hirmeos::MetricsTracker.new.submit_to_hirmeos(resource)
      end
    end
  end
end
