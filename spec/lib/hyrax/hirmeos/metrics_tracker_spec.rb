# frozen_string_literal: true
require 'hyrax/hirmeos/metrics_tracker'
require 'rails_helper'

RSpec.describe Hyrax::Hirmeos::MetricsTracker do
  subject(:tracker) { described_class.new }
  let(:work) { create(:work_with_files) }
  let(:file_set) { create(:file_with_work) }
  let(:hirmeos_uuid) { "48b61e0a-f92c-4533-8270-b4caa98cbcfb" }
  let(:hirmeos_work_data) do
    {
      count: 14,
      code: 200,
      data: [
        {
          URI: "https://dashboard.bertie.ubiquityrepo-ah.website/concern/pacific_images/92cfa1e1-4ab3-4fd3-9140-90eda7cd5ed9",
          canonical: true,
          score: 0,
          URI_parts: {
            scheme: "https",
            value: "dashboard.bertie.ubiquityrepo-ah.website/concern/pacific_images/92cfa1e1-4ab3-4fd3-9140-90eda7cd5ed9"
          },
          work: {
            URI: [],
            type: "repository-work",
            title: ["Pictures of TWICE"],
            UUID: hirmeos_uuid
          }
        }
      ]
    }
  end

  before do
    Hyrax::Hirmeos::MetricsTracker.username = "UsernameTest"
    Hyrax::Hirmeos::MetricsTracker.password = "Password"
    path = "#{Hyrax::Hirmeos::MetricsTracker.translation_base_url}/translate?uri=urn:uuid:{id}"

    stub_request(:get, Addressable::Template.new(path)).to_return(status: 200, body: hirmeos_work_data.to_json)
  end

  describe '#register_work_to_hirmeos' do
    it 'Makes a call to the translator works endpoint if the work is not already registered' do
      stub_request(:get, "#{Hyrax::Hirmeos::MetricsTracker.translation_base_url}/translate?uri=urn:uuid:#{work.id}").to_return(status: 400)
      structure = {
        "title": [
          work.title[0].to_s
        ],
        "uri": [
          {
            "uri": "https://localhost:3000/concern/generic_works/#{work.id}",
            "canonical": true
          },
          {
            "uri": "urn:uuid:#{work.id}"
          }
        ],
        "type": "repository-work",
        "parent": nil,
        "children": nil
      }
      tracker.submit_to_hirmeos(work)
      expect(a_request(:post, tracker.translation_base_url + "/works").with(body: structure.to_json)).to have_been_made.at_least_once
    end

    it 'does not call the register endpoint if a work is already registered' do
      tracker.submit_to_hirmeos(work)
      expect(a_request(:post, tracker.translation_base_url + "/works")).not_to have_been_made
    end
  end

  describe '#submit_file_to_hirmeos' do
    it 'Makes a request to the translator uri endpoint to add files to an existing work' do
      file_url = tracker.file_url(file_set)
      tracker.submit_file_to_hirmeos(file_set)

      expect(a_request(:post, tracker.translation_base_url + "/uris")
                 .with(body: { "URI": file_url.to_s, "UUID": hirmeos_uuid }.to_json))
        .to have_been_made.at_least_once

      expect(a_request(:post, tracker.translation_base_url + "/uris")
                 .with(body: { "URI": "urn:uuid:#{file_set.id}", "UUID": hirmeos_uuid }.to_json))
        .to have_been_made.at_least_once
    end
  end

  describe '#submit_diff_to_hirmeos' do
    before do
      path = "#{Hyrax::Hirmeos::MetricsTracker.translation_base_url}/works?uuid=#{hirmeos_uuid}"
      stub_request(:get, path).to_return(status: 200, body: hirmeos_work_data[:data].to_json)
    end

    it 'Makes a request to the translator uri endpoint to if there are missing links' do
      file_url = tracker.file_url(work.file_sets.first)
      tracker.submit_diff_to_hirmeos(work)
      work.file_sets.each do |file_set|
        expect(
          a_request(:post, tracker.translation_base_url + "/uris")
            .with(body: { "URI": file_url.to_s, "UUID": hirmeos_uuid }.to_json)
        ).to have_been_made.at_least_once

        expect(
          a_request(:post, tracker.translation_base_url + "/uris")
            .with(body: { "URI": "urn:uuid:#{file_set.id}", "UUID": hirmeos_uuid }.to_json)
        ).to have_been_made.at_least_once
      end
    end
  end

  describe '#resource_to_hirmeos_json' do
    it "Returns a Client Work Object" do
      expect(tracker.resource_to_hirmeos_json(work)).to be_a_kind_of(Hyrax::Hirmeos::Client::Work)
    end
  end

  describe '#resource_to_hirmeos_json_with_files' do
    let(:result) { tracker.resource_to_hirmeos_json_with_files(work, hirmeos_uuid) }

    it "Returns a Array" do
      expect(result).to be_an Array
    end

    it "Returns an item per work and file link" do
      expect(result.count).to eq 6
    end

    it "returns the work links" do
      expect(result).to include({ canonical: true, uri: "https://localhost:3000/concern/generic_works/#{work.id}" })
      expect(result).to include({ uri: "urn:uuid:#{work.id}" })
    end

    it "returns the file links" do
      work.file_sets.each do |file_set|
        expect(result).to include({ URI: "https://localhost:3000/downloads/#{file_set.id}", UUID: hirmeos_uuid })
        expect(result).to include({ URI: "urn:uuid:#{file_set.id}", UUID: hirmeos_uuid })
      end
    end
  end

  describe '#get_translator_work_id' do
    it "Returns the HIRMEOS ID of a work already registed in HIRMEOS" do
      expect(tracker.get_translator_work_id(work.id)).to eq(hirmeos_uuid)
    end
  end

  describe '#file_url' do
    it 'returns the download link of the file' do
      expect(tracker.file_url(file_set)).to eq("https://localhost:3000/downloads/#{file_set.id}")
    end
  end

  describe '#resource_to_link_update_hash' do
    it 'creates an update hash for each file' do
      file_url = tracker.file_url(file_set)
      expect(tracker.resource_to_link_update_hash(file_url, "1234-abcd-zyxw")).to eq({ URI: file_url, UUID: "1234-abcd-zyxw" })
    end
  end

  describe '#resource_to_uuid_update_hash' do
    it 'creates an update hash for each file' do
      expect(tracker.resource_to_uuid_update_hash(file_set.id, "1234-abcd-zyxw")).to eq({ URI: "urn:uuid:#{file_set.id}", UUID: "1234-abcd-zyxw" })
    end
  end
end
