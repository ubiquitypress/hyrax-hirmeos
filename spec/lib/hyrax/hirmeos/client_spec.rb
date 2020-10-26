# frozen_string_literal: true
require 'hyrax/hirmeos/client'
require 'rails_helper'

RSpec.describe Hyrax::Hirmeos::Client do
  WebMock.allow_net_connect!
  subject(:client) { described_class.new("archivist1@example.com", "password", "https://metrics-api.operas-eu.org/events", "https://tokens.ubiquity.press/", "https://translator.ubiquity.press") }

  before do
    WebMock.allow_net_connect!
    stub_request(:any, "https://translator.ubiquity.press/works")
    stub_request(:post, "https://tokens.ubiquity.press/tokens").to_return(status: 200, body: { "data" => [{ "token" => "exampleToken" }], "code" => 200, "status" => "ok" }.to_json)
  end

  describe '#post_work' do
    it "Makes a call to the translation api works endpoint" do
      work = create(:work)
      WebMock.disallow_net_connect!
      client.post_work(work)
      expect(a_request(:post, "https://translator.ubiquity.press/works")).to have_been_made.at_least_once
    end
  end

  describe '#get_work' do
    it 'Makes a call to get the work' do
      work = create(:work)
      stub_request(:get, "https://metrics-api.operas-eu.org/events?filter=work_uri:urn:uuid:#{work.id}")
      WebMock.disallow_net_connect!
      client.get_work(work.id)
      expect(a_request(:get, "https://metrics-api.operas-eu.org/events?filter=work_uri:urn:uuid:#{work.id}")).to have_been_made.at_least_once
    end
  end

  describe '#request_token' do
    it 'makes a call to the token base url' do
      WebMock.disallow_net_connect!
      token = client.request_token
      expect(a_request(:post, "https://tokens.ubiquity.press/tokens")).to have_been_made.at_least_once
      expect(token).to eq("exampleToken")
    end
  end
end
