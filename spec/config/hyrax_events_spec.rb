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
      expect(FileSetAttachedEventJob).to receive(:perform_later).with(file_set, user)
      Hyrax.config.callback.run(:after_create_fileset, file_set, user, warn: false)
    end

    it 'queues a Hyrax::Hirmeos::HirmeosFileUpdaterJob' do
      expect(Hyrax::Hirmeos::HirmeosFileUpdaterJob).to receive(:perform_later).with(file_set)#
      Hyrax.config.callback.run(:after_create_fileset, file_set, user, warn: false)
      expect(Hyrax::Hirmeos::HirmeosFileUpdaterJob).to have_been_enqueued.exactly(:once)
    end
  end
end
