# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::Actors::HirmeosActor do
  subject(:actor)  { described_class.new(next_actor) }
  let(:ability)    { Ability.new(user) }
  let(:env)        { Hyrax::Actors::Environment.new(work, ability, {}) }
  let(:next_actor) { Hyrax::Actors::Terminator.new }
  let(:user)       { build(:user) }
  let(:work)       { create(:work) }

  before { ActiveJob::Base.queue_adapter = :test }

  describe '#create' do
    it "enqueues the hirmeos registration job" do
      expect { actor.create(env) }.to have_enqueued_job(Hyrax::Hirmeos::HirmeosRegistrationJob).with(work)
    end
  end
end
