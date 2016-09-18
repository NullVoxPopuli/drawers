source 'https://rubygems.org'

# Specify your gem's dependencies in authorizable.gemspec
gemspec

# include the test app's gemfile
local_gemfile = File.join(File.expand_path('..', __FILE__), 'spec/support/rails_app/Gemfile')
eval_gemfile local_gemfile if File.readable?(local_gemfile)

gem 'codeclimate-test-reporter', gorup: :test, require: nil
