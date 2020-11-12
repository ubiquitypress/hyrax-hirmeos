# frozen_string_literal: true
require 'rails_helper'
# Generators are not automatically loaded by Rails
require 'generators/hyrax/hirmeos/install_generator'

describe Hyrax::Hirmeos::InstallGenerator, type: :generator do
  # Tell the generator where to put its output (what it thinks of as Rails.root)
  destination Hyrax::Hirmeos::Engine.root.join("tmp", "generator_testing")

  let(:initializer_path) { File.join('config', 'initializers', 'hyrax_hirmeos.rb') }
  let(:routes_path) { File.join('config', 'routes.rb') }

  before do
    # This will wipe the destination root dir
    prepare_destination

    FileUtils.mkdir_p destination_root.join(File.dirname(initializer_path))
    FileUtils.cp Rails.root.join(initializer_path), destination_root.join(initializer_path)

    FileUtils.mkdir_p destination_root.join(File.dirname(routes_path))
    FileUtils.cp Rails.root.join(routes_path), destination_root.join(routes_path)
  end

  describe 'generate_config' do
    it 'copies the initializer' do
      run_generator
      expect(file(initializer_path)).to exist
    end
  end

  describe 'inject_engine_routes' do
    it 'mounts engine' do
      run_generator
      expect(file(routes_path)).to contain("mount Hyrax::Hirmeos::Engine, at: '/', as: 'hyrax_hirmeos'")
    end
  end
end
