# frozen_string_literal: true
require 'hyrax/hirmeos/client'
require 'rails_helper'

RSpec.describe Hyrax::Hirmeos::Client do
  WebMock.allow_net_connect!
  let(:subject) { described_class.new("archivist1@example.com", "secure_password", "https://metrics-api.operas-eu.org/events",
                                      "https://tokens.ubiquity.press/", "https://translator.ubiquity.press") }

  before do
    WebMock.allow_net_connect!
    stub_request(:any, "https://translator.ubiquity.press/works")
    stub_request(:post, "https://tokens.ubiquity.press/tokens").to_return(status: 200, body: {"data"=>[{"token"=>"exampleToken"}], "code"=>200, "status"=>"ok"}.to_json)
  end

  describe '#post_work' do
    it "Makes a call to the translation api works endpoint" do
      work = create(:work, visibility:"open")
      WebMock.disallow_net_connect!
      subject.post_work(work: work)
      expect(a_request(:post, "https://translator.ubiquity.press/works")).to have_been_made.at_least_once
    end
  end

  describe '#get_work' do
    it 'Makes a call to get the work' do
      work = create(:work)
      stub_request(:get, "https://metrics-api.operas-eu.org/events?filter=work_uri:urn:uuid:#{work.id}")
      WebMock.disallow_net_connect!
      subject.get_work(work.id)
      expect(a_request(:get, "https://metrics-api.operas-eu.org/events?filter=work_uri:urn:uuid:#{work.id}")).
      to have_been_made.at_least_once
    end
  end

  describe '#get_token' do
    it 'makes a call to the token base url' do
      WebMock.disallow_net_connect!
      token = subject.get_token
      expect(a_request(:post, "https://tokens.ubiquity.press/tokens")).to have_been_made.at_least_once
      expect(token).to eq("exampleToken")
    end
  end
end
