source 'https://rubygems.org'

# include the test app's gemfile
local_gemfile = File.join(File.expand_path('..', __FILE__), 'spec/support/rails_app/Gemfile')
eval_gemfile local_gemfile if File.readable?(local_gemfile)

# Specify your gem's dependencies in authorizable.gemspec
gemspec
