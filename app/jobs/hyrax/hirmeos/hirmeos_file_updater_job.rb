# frozen_string_literal: true
module Hyrax
  module Hirmeos
    class HirmeosFileUpdaterJob < ApplicationJob
      def perform(resource)
        Hyrax::Hirmeos::MetricsTracker.new.submit_files_to_hirmeos(resource)
      end
    end
  end
end
