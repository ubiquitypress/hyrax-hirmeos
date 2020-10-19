# frozen_string_literal: true
require 'hyrax/hirmeos/metrics_tracker'
require 'rails_helper'

RSpec.describe Hyrax::Hirmeos::MetricsTracker do
  WebMock.allow_net_connect!
  let(:subject) { described_class.new("UsernameTest", "Password", "https://metrics-api.operas-eu.org/events",
                                      "www.dummy-token-url.org", "https://translator.ubiquity.press") }

  before do
    stub_request(:post, "https://translator.ubiquity.press/works")
  end

  describe '#register_work_to_hirmeos' do
    it 'Makes a call to the hirmeos API' do
      work = create(:work, visibility: "open")
      structure = {
        "title": [
          "#{work.title[0]}"
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
      subject.submit_to_hirmeos(work)
      expect(a_request(:post, subject.translation_base_url + "/works").with(body:structure.to_json)).to have_been_made.at_least_once
    end
  end

  describe '#resource_to_hirmeos_json' do
    it "Returns a Client Work Object" do
      WebMock.allow_net_connect!
      work = create(:work)
      expect(subject.resource_to_hirmeos_json(work)).to be_a_kind_of(Hyrax::Hirmeos::Client::Work)
    end
  end
end
