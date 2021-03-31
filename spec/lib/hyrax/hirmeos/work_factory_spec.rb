# frozen_string_literal: true
require 'hyrax/hirmeos/work_factory'
require 'hyrax/hirmeos/client'
require 'rails_helper'

RSpec.describe Hyrax::Hirmeos::WorkFactory do
  WebMock.allow_net_connect!
  let(:work) { create(:work) }
  let(:work_with_file) { create(:work_with_one_file) }
  let(:work_with_multiple_files) { create(:work_with_files) }

  it "Creates works with the correct structure" do
    structure = {
      "title": [
        work.title[0].to_s
      ],
      "uri": [
        {
          "uri": "http://localhost:3000/concern/generic_works/#{work.id}",
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
    factory_work = described_class.for(resource: work)
    expect(factory_work.to_json).to eq(structure.to_json)
  end

  it "Adds download link of a file when there is a file avalible" do
    structure = {
      "title": [
        work_with_file.title[0].to_s
      ],
      "uri": [
        {
          "uri": "http://localhost:3000/concern/generic_works/#{work_with_file.id}",
          "canonical": true
        },
        {
          "uri": "urn:uuid:#{work_with_file.id}"
        },
        {
          "uri": "http://localhost:3000/downloads/#{work_with_file.file_sets[0].id}"
        }
      ],
      "type": "repository-work",
      "parent": nil,
      "children": nil
    }
    factory_work = described_class.for(resource: work_with_file)
    expect(factory_work.to_json).to eq(structure.to_json)
  end

  it "Adds multiple download links when there are multiple files" do
    structure = {
      "title": [
        work_with_multiple_files.title[0].to_s
      ],
      "uri": [
        {
          "uri": "http://localhost:3000/concern/generic_works/#{work_with_multiple_files.id}",
          "canonical": true
        },
        {
          "uri": "urn:uuid:#{work_with_multiple_files.id}"
        },
        {
          "uri": "http://localhost:3000/downloads/#{work_with_multiple_files.file_sets[0].id}"
        },
        {
          "uri": "http://localhost:3000/downloads/#{work_with_multiple_files.file_sets[1].id}"
        }
      ],
      "type": "repository-work",
      "parent": nil,
      "children": nil
    }
    factory_work = described_class.for(resource: work_with_multiple_files)
    expect(factory_work.to_json).to eq(structure.to_json)
  end
end
