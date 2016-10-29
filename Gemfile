# frozen_string_literal: true
source 'https://rubygems.org'

# Specify your gem's dependencies in authorizable.gemspec
gemspec

# include the test app's gemfile
local_gemfile = File.join(File.expand_path('..', __FILE__), 'spec/support/rails_app/Gemfile')
eval_gemfile local_gemfile if File.readable?(local_gemfile)

gem 'codeclimate-test-reporter', group: :test, require: nil

version = ENV['RAILS_VERSION'] || '5.0'

if version == 'master'
  gem 'rack', github: 'rack/rack'
  gem 'arel', github: 'rails/arel'
  git 'https://github.com/rails/rails.git' do
    gem 'railties'
    gem 'activesupport'
    gem 'activemodel'
    gem 'actionpack'
    gem 'activerecord', group: :test
    # Rails 5
    gem 'actionview'
  end
else
  gem_version = "~> #{version}.0"
  gem 'railties', gem_version
  gem 'activesupport', gem_version
  gem 'activemodel', gem_version
  gem 'actionpack', gem_version
  gem 'activerecord', gem_version, group: :test
end
