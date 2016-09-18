# -*- encoding: utf-8 -*-
# frozen_string_literal: true

# allows bundler to use the gemspec for dependencies
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'rails_module_unification/version'

Gem::Specification.new do |s|
  s.name        = 'rails_module_unification'
  s.version     = RailsModuleUnification::VERSION
  s.platform    = Gem::Platform::RUBY
  s.license     = 'MIT'
  s.authors     = ['L. Preston Sego III']
  s.email       = 'LPSego3+dev@gmail.com'
  s.homepage    = 'https://github.com/NullVoxPopuli/rails_module_unification'
  s.summary     = "RailsModuleUnification-#{RailsModuleUnification::VERSION}"
  s.description = 'Ember\'s Module Unification brought to Rails'

  s.files        = Dir['CHANGELOG.md', 'LICENSE', 'README.md', 'lib/**/*']
  s.require_path = 'lib'

  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  s.required_ruby_version = '>= 2.0'

  s.add_runtime_dependency 'activesupport'

  # Quality Control
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rspec'

  # Debugging
  s.add_development_dependency 'awesome_print'
  s.add_development_dependency 'pry-byebug'

  # for testing a gem with a rails app (controller specs)
  # https://codingdaily.wordpress.com/2011/01/14/test-a-gem-with-the-rails-3-stack/
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rails'
  s.add_development_dependency 'factory_girl'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'rspec-rails'
end
