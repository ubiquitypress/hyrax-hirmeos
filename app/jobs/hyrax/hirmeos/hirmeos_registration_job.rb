# frozen_string_literal: true
module Hyrax
  module Hirmeos
    class HirmeosRegistrationJob < ApplicationJob
      # If there is no available connection, drop the job
      discard_on Faraday::ConnectionFailed

      def perform(resource_id)
        resource = ActiveFedora::Base.find(resource_id)
        Hyrax::Hirmeos::MetricsTracker.new.submit_to_hirmeos(resource)
      end
    end
  end
end
