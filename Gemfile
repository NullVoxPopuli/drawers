# frozen_string_literal: true
source 'https://rubygems.org'

# Specify your gem's dependencies in authorizable.gemspec
gemspec

# include the test app's gemfile
local_gemfile = File.join(File.expand_path('..', __FILE__), 'spec/support/rails_app/Gemfile')
eval_gemfile local_gemfile if File.readable?(local_gemfile)

group :test do
  gem 'simplecov'
  gem 'codeclimate-test-reporter', group: :test, require: nil
end

version = ENV['RAILS_VERSION'] || '5.0'

if version == 'master'
  gem 'rails', github: 'rails/rails'
else
  gem 'rails', "~> 5.1.4"
end
