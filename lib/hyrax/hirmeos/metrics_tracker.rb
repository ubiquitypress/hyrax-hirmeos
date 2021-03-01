# frozen_string_literal: true
require "hyrax/hirmeos/client"
require "hyrax/hirmeos/work_factory"
class Hyrax::Hirmeos::MetricsTracker
  class_attribute :username, :password, :metrics_base_url, :translation_base_url, :secret

  def client
    @client ||= Hyrax::Hirmeos::Client.new(username, password, metrics_base_url, translation_base_url, secret)
  end

  def submit_to_hirmeos(work)
    uuid = work.id
    response = client.get_work(uuid)
    return if response.success?
    client.post_work(resource_to_hirmeos_json(work))
  end

  def resource_to_hirmeos_json(work)
    Hyrax::Hirmeos::WorkFactory.for(resource: work)
  end
end
