# helper.rb

require 'minitest/autorun'
require 'minitest/mock'
require 'minitest/spec'
require 'minitest-spec-context'
require 'vcr'
require 'webmock/minitest'

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require 'eodhd'

VCR.configure do |config|
  config.cassette_library_dir = File.expand_path('./fixtures/vcr_cassettes', __dir__)
  config.hook_into :webmock
  config.filter_sensitive_data('<API_TOKEN>'){ENV['EODHD_API_TOKEN']}
end
