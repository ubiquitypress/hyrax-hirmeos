# frozen_string_literal: true
require 'hyrax/hirmeos/client'
require 'rails_helper'

RSpec.describe Hyrax::Hirmeos::Client do
  subject(:client) { described_class.new("archivist1@example.com", "password", "https://dummy-metrics-api/events", "https://tokens.dummy.endpoint/", "https://translator.dummy.endpoint") }
  let(:work) { create(:work) }

  before do
    Rails.application.routes.default_url_options[:host] = 'localhost:3000'
    stub_request(:any, "https://translator.dummy.endpoint/works")
    stub_request(:post, "https://tokens.dummy.endpoint/tokens").to_return(status: 200, body: { "data" => [{ "token" => "exampleToken" }], "code" => 200, "status" => "ok" }.to_json)
  end

  describe '#post_work' do
    it "Makes a call to the translation api works endpoint" do
      client.post_work(work)
      expect(a_request(:post, "https://translator.dummy.endpoint/works")).to have_been_made.at_least_once
    end
  end

  describe '#get_work' do
    it 'Makes a call to get the work' do
      stub_request(:get, "https://dummy-metrics-api/events?filter=work_uri:urn:uuid:#{work.id}")
      client.get_work(work.id)
      expect(a_request(:get, "https://dummy-metrics-api/events?filter=work_uri:urn:uuid:#{work.id}")).to have_been_made.at_least_once
    end
  end

  describe '#request_token' do
    it 'makes a call to the token base url' do
      token = client.request_token
      expect(a_request(:post, "https://tokens.dummy.endpoint/tokens")).to have_been_made.at_least_once
      expect(token).to eq("exampleToken")
    end
  end
end
