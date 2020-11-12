# frozen_string_literal: true
require 'hyrax/hirmeos/client'
require 'rails_helper'

RSpec.describe Hyrax::Hirmeos::Client do
  subject(:client) do
    described_class.new(Hyrax::Hirmeos::MetricsTracker.username,
                                         Hyrax::Hirmeos::MetricsTracker.password,
                                         Hyrax::Hirmeos::MetricsTracker.metrics_base_url,
                                         Hyrax::Hirmeos::MetricsTracker.token_base_url,
                                         Hyrax::Hirmeos::MetricsTracker.translation_base_url)
  end
  let(:work) { create(:work) }

  describe '#post_work' do
    it "Makes a call to the translation api works endpoint" do
      client.post_work(work)
      expect(a_request(:post, "#{Hyrax::Hirmeos::MetricsTracker.translation_base_url}/works")).to have_been_made.at_least_once
    end
  end

  describe '#get_work' do
    it 'Makes a call to get the work' do
      client.get_work(work.id)
      expect(a_request(:get, "#{Hyrax::Hirmeos::MetricsTracker.metrics_base_url}/events?filter=work_uri:urn:uuid:#{work.id}")).to have_been_made.at_least_once
    end
  end

  describe '#request_token' do
    it 'makes a call to the token base url' do
      token = client.request_token
      expect(a_request(:post, "#{Hyrax::Hirmeos::MetricsTracker.token_base_url}/tokens")).to have_been_made.at_least_once
      expect(token).to eq("exampleToken")
    end
  end
end
