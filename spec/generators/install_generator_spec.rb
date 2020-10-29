# frozen_string_literal: true
require 'rails_helper'
# Generators are not automatically loaded by Rails
require 'generators/hyrax/hirmeos/install_generator'

describe Hyrax::Hirmeos::InstallGenerator, type: :generator do
  # Tell the generator where to put its output (what it thinks of as Rails.root)
  destination Hyrax::Hirmeos::Engine.root.join("tmp", "generator_testing")

  before do
    # This will wipe the destination root dir
    prepare_destination
  end

  describe 'generate_config' do
    it 'copies the initializer' do
      run_generator
      expect(file("hyrax_hirmeos.rb")).to exist
    end
  end
end
