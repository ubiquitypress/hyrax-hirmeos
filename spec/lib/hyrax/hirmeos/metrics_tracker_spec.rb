# frozen_string_literal: true
require 'hyrax/hirmeos/metrics_tracker'
require 'rails_helper'

RSpec.describe Hyrax::Hirmeos::MetricsTracker do
  subject(:tracker) { described_class.new }

  before do
    tracker.username = "UsernameTest"
    tracker.password = "Password"
    tracker.metrics_base_url = "https://metrics-api.operas-eu.org"
    tracker.token_base_url = "https://tokens.ubiquity.press/"
    tracker.translation_base_url = "https://translator.ubiquity.press"
    WebMock.allow_net_connect!
    stub_request(:post, "https://translator.ubiquity.press/works")
    stub_request(:post, "https://tokens.ubiquity.press/tokens").to_return(status: 200, body: { "data" => [{ "token" => "exampleToken" }], "code" => 200, "status" => "ok" }.to_json)
  end

  describe '#register_work_to_hirmeos' do
    it 'Makes a call to the register API if the work is not already registered' do
      work = create(:work, visibility: "open")
      stub_request(:get, "https://metrics-api.operas-eu.org/events?filter=work_uri:urn:uuid:#{work.id}").to_return(status: 400)
      structure = {
        "title": [
          work.title[0].to_s
        ],
        "uri": [
          {
            "uri": "http://localhost:3000/concern/generic_works/#{work.id}",
            "canonical": true
          }
        ],
        "type": "other",
        "parent": nil,
        "children": nil
      }
      WebMock.disallow_net_connect!
      tracker.submit_to_hirmeos(work)
      expect(a_request(:post, tracker.translation_base_url + "/works").with(body: structure.to_json)).to have_been_made.at_least_once
    end

    it 'does not call the register endpoint if a work is already registered' do
      work = create(:work)
      stub_request(:get, "https://metrics-api.operas-eu.org/events?filter=work_uri:urn:uuid:#{work.id}").to_return(status: 200)
      WebMock.disallow_net_connect!
      tracker.submit_to_hirmeos(work)
      expect(a_request(:post, tracker.translation_base_url + "/works")).not_to have_been_made
    end
  end

  describe '#resource_to_hirmeos_json' do
    it "Returns a Client Work Object" do
      work = create(:work)
      expect(tracker.resource_to_hirmeos_json(work)).to be_a_kind_of(Hyrax::Hirmeos::Client::Work)
    end
  end
end
