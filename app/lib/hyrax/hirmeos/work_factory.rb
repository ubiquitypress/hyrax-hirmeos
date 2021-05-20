# frozen_string_literal: true
require "hyrax/hirmeos/client"

class Hyrax::Hirmeos::WorkFactory
  def self.for(resource:)
    work = Hyrax::Hirmeos::Client::Work.new
    work.title = resource.title
    work.uri = [{ uri: resource_url(resource), canonical: true },
                { uri: "urn:uuid:#{resource.id}" }]
    work.type = "repository-work"
    work
  end

  def self.resource_url(work)
    Rails.application.routes.url_helpers.polymorphic_url(work)
  end
end
