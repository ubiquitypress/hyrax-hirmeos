# frozen_string_literal: true
require 'rails/generators'
require 'rails/generators/model_helpers'

class Hyrax::Hirmeos::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../../../../../config/initializers', __FILE__)

  def generate_config
    # rubocop:disable Style/RedundantSelf
    # For some reason I had to use self.destination_root here to get all contexts to work (calling from hyrax app, calling from this engine to test app, rspec tests)
    self.destination_root = Rails.root if self.destination_root.blank? || self.destination_root == Hyrax::Hirmeos::Engine.root.to_s
    initializer_file = File.join(self.destination_root, 'config/initializers/hyrax_hirmeos.rb')
    # rubocop:enable Style/RedundantSelf

    copy_file "hyrax_hirmeos.rb", initializer_file
  end

  def mount_engine_routes
    inject_into_file 'config/routes.rb', after: /mount Hyrax::Engine, at: '\S*'\n/ do
      "  mount Hyrax::Hirmeos::Engine, at: '/', as: 'hyrax_hirmeos'\n"
    end
  end
end
