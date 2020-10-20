# frozen_string_literal: true
require 'hyrax/hirmeos/work_factory'
require 'hyrax/hirmeos/client'
require 'rails_helper'

RSpec.describe Hyrax::Hirmeos::WorkFactory do
  WebMock.allow_net_connect!
  let(:work) { create(:work) }

  it "Creates works with the correct structure" do
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
    factory_work = Hyrax::Hirmeos::WorkFactory.for(resource: work)
    expect(factory_work.to_json).to eq(structure.to_json)
  end
end
