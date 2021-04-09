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

  def get_work(uuid)
    id_translation_connection.get("/translate?uri=urn:uuid:#{uuid}")
  end

  def post_files(data)
    id_translation_connection.post('/uris', data)
  end

  def generate_token(payload = build_payload)
    JWT.encode payload, @secret
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
    token = generate_token
    Faraday.new(translation_base_url) do |conn|
      conn.adapter Faraday.default_adapter # net/http
      conn.authorization :Bearer, token
    end
  end

  def metrics_connection
    token = generate_token
    Faraday.new(metrics_base_url) do |conn|
      conn.adapter Faraday.default_adapter # net/http
      conn.authorization :Bearer, token
    end
  end
end
