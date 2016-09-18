# Something weird is going on with the documented setup...
if ENV['TRAVIS']
  ENV['CODECLIMATE_REPO_TOKEN'] = 'd1d3df95e4c3d80f789dd38e0af3efa1eb7f18485d18fee6fdd754e3e08f858b'
end

if ENV['CODECLIMATE_REPO_TOKEN']
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end
