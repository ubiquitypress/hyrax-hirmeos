# frozen_string_literal: true
require 'hyrax/hirmeos/client'
require 'rails_helper'

RSpec.describe Hyrax::Hirmeos::Client do
  WebMock.allow_net_connect!
  let(:subject) { described_class.new("Username", "Password", "https://metrics-api.operas-eu.org/events",
                                      "www.dummy-token-url.org", "https://translator.ubiquity.press") }

  describe '#post_work' do
    it "Makes a call to the translation api works endpoint" do
      stub_request(:any, "https://translator.ubiquity.press/works")
      work = create(:work, visibility: 'open')
      WebMock.disable_net_connect!
      subject.post_work(work: work)
      expect(a_request(:post, "https://translator.ubiquity.press/works")).to have_been_made.at_least_once
    end
  end
end
