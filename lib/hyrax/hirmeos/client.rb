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

  def post_work(work: work)
    con = id_translation_connection
    con.post('/works', work.to_json)
  end

  private

  def id_translation_connection
    Faraday.new(translation_base_url) do |conn|
      conn.adapter Faraday.default_adapter # net/http
    end
  end
end
