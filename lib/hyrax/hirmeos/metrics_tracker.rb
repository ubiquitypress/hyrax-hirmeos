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

  def submit_files_to_hirmeos(work)
    uuid = work.id
    hirmeos_id = get_translator_work_id(uuid)
    files = file_urls(work)
    files.each { |file_url| client.post_files(resource_to_update_hash(file_url, hirmeos_id))}
  end

  def get_translator_work_id(uuid)
    response = client.get_work(uuid)
    work_json = JSON.parse(response.body) if response.success?
    translator_work_id = work_json['data'][0]['work']['UUID'] if work_json.present?
  end

  def resource_to_hirmeos_json(work)
    Hyrax::Hirmeos::WorkFactory.for(resource: work)
  end

  def file_urls(work)
    files = work.file_sets
    return if files.blank?
    links = files.map { |file| Hyrax::Engine.routes.url_helpers.download_url(id: file) }
  end

  def resource_to_update_hash(file_url, hirmeos_id)
    {'URI': file_url, 'UUID': hirmeos_id}
  end
end
