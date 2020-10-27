# frozen_string_literal: true
class Hyrax::Hirmeos::Client
  attr_accessor :username, :password, :metrics_base_url, :token_base_url, :translation_base_url

  def initialize(username, password, metrics_base_url, token_base_url, translation_base_url)
    @username = username
    @password = password
    @metrics_base_url = metrics_base_url
    @token_base_url = token_base_url
    @translation_base_url = translation_base_url
  end

  def post_work(work)
     id_translation_connection.post('/works', work.to_json)
  end

  def get_work(uuid)
    metrics_connection.get("/events?filter=work_uri:urn:uuid:#{uuid}") # This will need to be made configurable I think?
  end

  def request_token
    response = Faraday.post(URI.join(token_base_url, 'tokens')), { email: username, password: password }.to_json
    token = JSON.parse(response[0].body).dig(:data)
    puts "AHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH"
    puts token
    token
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
