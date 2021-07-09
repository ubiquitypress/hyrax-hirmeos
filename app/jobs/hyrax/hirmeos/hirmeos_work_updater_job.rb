# frozen_string_literal: true
module Hyrax
  module Hirmeos
    class HirmeosWorkUpdaterJob < ApplicationJob
      # If there is no available connection, drop the job
      discard_on Faraday::ConnectionFailed

      def perform(resource_id)
        resource = ActiveFedora::Base.find(resource_id)
        service.submit_diff_to_hirmeos(resource)
      end

      private

      def service
        @_service ||= Hyrax::Hirmeos::MetricsTracker.new
      end
    end
  end
end
