# frozen_string_literal: true
require "hyrax/hirmeos/client"
require "hyrax/hirmeos/work_factory"
class Hyrax::Hirmeos::MetricsTracker
  class_attribute :username, :password, :metrics_base_url, :translation_base_url, :secret, :work_factory

  def client
    @client ||= Hyrax::Hirmeos::Client.new(username, password, metrics_base_url, translation_base_url, secret)
  end

  def submit_to_hirmeos(work)
    uuid = work.id
    response = client.get_work(uuid)
    return if response.success?
    client.post_work(resource_to_hirmeos_json(work))
  end

  def submit_file_to_hirmeos(file_set)
    work_id = file_set.parent_work_ids.first
    hirmeos_id = get_translator_work_id(work_id)
    client.post_files(resource_to_link_update_hash(file_url(file_set), hirmeos_id))
    client.post_files(resource_to_uuid_update_hash(file_set.id, hirmeos_id))
  end

  def get_translator_work_id(uuid)
    response = client.get_work(uuid)
    work_json = JSON.parse(response.body) if response.success?
    work_json.dig('data', 0, 'work', 'UUID') if work_json.present?
  end

  def resource_to_hirmeos_json(work)
    Hyrax::Hirmeos::MetricsTracker.work_factory.for(resource: work)
  end

  def file_url(file)
    Hyrax::Engine.routes.url_helpers.download_url(id: file)
  end

  def resource_to_link_update_hash(file_url, hirmeos_id)
    { 'URI': file_url, 'UUID': hirmeos_id }
  end

  def resource_to_uuid_update_hash(file_set_id, hirmeos_id)
    { 'URI': "urn:uuid:#{file_set_id}", 'UUID': hirmeos_id }
  end
end
