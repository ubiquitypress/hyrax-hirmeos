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
    metrics_connection.get("/events?filter=work_uri:urn:uuid:#{uuid}") # This will need to be made configurable I think?
  end

  def generate_token(payload)
    JWT.encode payload, @secret
  end

  Work = Struct.new(:title, :uri, :type, :parent, :children)

  private

  def id_translation_connection
    token = request_token
    Faraday.new(translation_base_url) do |conn|
      conn.adapter Faraday.default_adapter # net/http
      conn.token_auth(token)
    end
  end

  def metrics_connection
    token = request_token
    Faraday.new(metrics_base_url) do |conn|
      conn.adapter Faraday.default_adapter # net/http
      conn.token_auth(token)
    end
  end
end
