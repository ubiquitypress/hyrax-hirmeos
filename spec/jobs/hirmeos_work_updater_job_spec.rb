# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::Hirmeos::HirmeosWorkUpdaterJob do
  let(:work) { create(:work_with_one_file) }

  describe '#perform' do
    let(:service) { instance_double(Hyrax::Hirmeos::MetricsTracker, submit_diff_to_hirmeos: true) }

    before do
      allow_any_instance_of(described_class).to receive(:service).and_return(service)
    end

    it "makes a call to hirmeos" do
      described_class.perform_now(work.id)
      expect(service).to have_received(:submit_diff_to_hirmeos).with(work)
    end
  end
end
