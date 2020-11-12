# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::Actors::HirmeosActor do
  subject(:actor)  { described_class.new(next_actor) }
  let(:ability)    { Ability.new(user) }
  let(:env)        { Hyrax::Actors::Environment.new(work, ability, {}) }
  let(:next_actor) { Hyrax::Actors::Terminator.new }
  let(:user)       { build(:user) }
  let(:work)       { build(:work) }

  describe '#create' do
    it "makes a call to hirmeos" do
      stub_request(:get, "#{Hyrax::Hirmeos::MetricsTracker.metrics_base_url}/events?filter=work_uri:urn:uuid:#{work.id}").to_return(status: 400)
      actor.create(env)
      expect(a_request(:post, "#{Hyrax::Hirmeos::MetricsTracker.translation_base_url}/works")).to have_been_made.at_least_once
    end
  end
end
