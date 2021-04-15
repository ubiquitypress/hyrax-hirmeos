# frozen_string_literal: true
RSpec.describe "hyrax_events using Hyrax callbacks" do
  let(:file_set) { create(:file_set) }
  let(:user) { create(:user) }
  ActiveJob::Base.queue_adapter = :test

  before do
    Hyrax.config.callback.set(:after_create_fileset) do |file_set, user|
      Hyrax::Hirmeos::HirmeosFileUpdaterJob.perform_later(file_set)
      FileSetAttachedEventJob.perform_later(file_set, user)
    end
  end

  describe "after_create_fileset" do
    it "queues a FileSetAttachedEventJob" do
      allow(FileSetAttachedEventJob).to receive(:perform_later)
      Hyrax.config.callback.run(:after_create_fileset, file_set, user, warn: false)
      expect(FileSetAttachedEventJob).to have_received(:perform_later).with(file_set, user)
    end

    it 'queues a Hyrax::Hirmeos::HirmeosFileUpdaterJob' do
      allow(Hyrax::Hirmeos::HirmeosFileUpdaterJob).to receive(:perform_later)
      Hyrax.config.callback.run(:after_create_fileset, file_set, user, warn: false)
      expect(Hyrax::Hirmeos::HirmeosFileUpdaterJob).to have_received(:perform_later).with(file_set)
      expect(Hyrax::Hirmeos::HirmeosFileUpdaterJob).to have_been_enqueued.exactly(:once)
    end
  end
end
