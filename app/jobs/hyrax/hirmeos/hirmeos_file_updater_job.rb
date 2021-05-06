# frozen_string_literal: true
module Hyrax
  module Hirmeos
    class HirmeosFileUpdaterJob < ApplicationJob
      def perform(resource_id)
        resource = ActiveFedora::Base.find(resource_id)
        Hyrax::Hirmeos::MetricsTracker.new.submit_file_to_hirmeos(resource)
      end
    end
  end
end
