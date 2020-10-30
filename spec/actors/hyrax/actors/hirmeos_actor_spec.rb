# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::Actors::HirmeosActor do
  subject(:actor)  { described_class.new(next_actor) }
  let(:ability)    { Ability.new(user) }
  let(:env)        { Hyrax::Actors::Environment.new(work, ability, {}) }
  let(:next_actor) { Hyrax::Actors::Terminator.new }
  let(:user)       { build(:user) }
  let(:work)       { build(:work) }

  before do
    Rails.application.routes.default_url_options[:host] = 'localhost:3000'
    stub_request(:any, "https://translations_base_url/works")
    stub_request(:post, "https://token_base_url/tokens").to_return(status: 200, body: { "data" => [{ "token" => "exampleToken" }], "code" => 200, "status" => "ok" }.to_json)
    stub_request(:get, "https://metrics_base_url/events?filter=work_uri:urn:uuid:#{work.id}").to_return(status: 400)
  end

  describe '#create' do
    it "makes a call to hirmeos" do
      actor.create(env)
      expect(a_request(:post, "https://translations_base_url/works")).to have_been_made.at_least_once
    end
  end
end
