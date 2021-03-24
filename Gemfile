# frozen_string_literal: true
source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'mimemagic', git: 'https://github.com/minad/mimemagic.git', ref: '01f92d86d15d85cfd0f20dabd025dcbd36a8a60f'

# Declare your gem's dependencies in hyrax-hirmeos.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use a debugger
# gem 'byebug', group: [:development, :test]

eval_gemfile File.expand_path('spec/internal_test_hyrax/Gemfile', File.dirname(__FILE__))
