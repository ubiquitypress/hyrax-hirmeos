# frozen_string_literal: true
require 'jwt'

class Hyrax::Hirmeos::Client
  attr_accessor :username, :password, :metrics_base_url, :translation_base_url, :secret

  def initialize(username, password, metrics_base_url, translation_base_url, secret)
    @username = username
    @password = password
    @metrics_base_url = metrics_base_url
    @translation_base_url = translation_base_url
    @secret = secret
  end

  def post_work(work)
    id_translation_connection.post('/works', work.to_json)
  end

  def get_work(hyku_uuid)
    id_translation_connection.get("/translate?uri=urn:uuid:#{hyku_uuid}")
  end

  def get_work_identifiers(hirmeos_uuid)
    id_translation_connection.get("/works?uuid=#{hirmeos_uuid}")
  end

  def delete_work(hirmeos_uuid)
    id_translation_connection.delete('/works', uuid: "urn:uuid:#{hirmeos_uuid}")
  end

  def post_files(data)
    id_translation_connection.post('/uris', data.to_json)
  end

  def generate_token(payload = build_payload)
    JWT.encode(payload, @secret)
  end

  Work = Struct.new(:title, :uri, :type, :parent, :children)

  private

  def build_payload
    {
      'authority': 'user',
      'email': '',
      'exp': Time.now.to_i + 900, # 15 minutes from creation recommended, which is 900 seconds
      'iat': Time.now.to_i,
      'name': '',
      'sub': ''
    }
  end

  def id_translation_connection
    connection_for(translation_base_url)
  end

  def metrics_connection
    connection_for(metrics_base_url)
  end

  def connection_for(url)
    Faraday.new(url) do |conn|
      conn.adapter Faraday.default_adapter # net/http
      conn.authorization :Bearer, generate_token
    end
  end
end
