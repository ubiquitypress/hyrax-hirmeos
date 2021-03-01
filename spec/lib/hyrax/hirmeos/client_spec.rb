# frozen_string_literal: true
require 'hyrax/hirmeos/client'
require 'rails_helper'
require 'jwt'

RSpec.describe Hyrax::Hirmeos::Client do
  subject(:client) do
    described_class.new(Hyrax::Hirmeos::MetricsTracker.username,
                                         Hyrax::Hirmeos::MetricsTracker.password,
                                         Hyrax::Hirmeos::MetricsTracker.metrics_base_url,
                                         Hyrax::Hirmeos::MetricsTracker.translation_base_url,
                                         Hyrax::Hirmeos::MetricsTracker.secret)
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

  describe '#generate_token' do
    it 'generates a token for authentication' do
      sample_payload = {
        "app": "hyku",
        "purpose": "test"
      }
      token = client.generate_token(sample_payload)
      expect(token).to be_present
      decoded_token = JWT.decode token, client.secret
      expect(decoded_token).to include(hash_including("app" => "hyku", "purpose" => "test"))
    end
  end

  it 'takes a default payload structure' do
    token = client.generate_token
    decoded_token = JWT.decode token, client.secret
    expect(decoded_token).to include(hash_including("iat" => a_kind_of(Integer), "exp" => a_kind_of(Integer)))
  end
end
