# frozen_string_literal: true
module Hyrax
  module Hirmeos
    class Engine < ::Rails::Engine
      isolate_namespace Hyrax::Hirmeos

      config.after_initialize do
        Hyrax::CurationConcern.actor_factory.use Hyrax::Actors::HirmeosActor

        # Prepend our views so they have precedence
        ActionController::Base.prepend_view_path(paths['app/views'].existent)
      end
    end
  end
end
