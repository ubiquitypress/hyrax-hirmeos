# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::Hirmeos::HirmeosRegistrationJob do
  let(:work) { create(:work) }

  describe '#perform' do
    it "makes a call to hirmeos" do
      stub_request(:get, "#{Hyrax::Hirmeos::MetricsTracker.metrics_base_url}/events?filter=work_uri:urn:uuid:#{work.id}").to_return(status: 400)
      described_class.perform_now(work)
      expect(a_request(:post, "#{Hyrax::Hirmeos::MetricsTracker.translation_base_url}/works")).to have_been_made.at_least_once
    end
  end
end
