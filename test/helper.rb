# helper.rb

# Skip webmock's http_rb adapter: it takes any HTTP::VERSION for the http gem's,
# and http.rb defines one, so it crashes trying to patch an HTTP::Client which
# isn't there. On case-insensitive filesystems its require 'http' loads http.rb.

gem 'webmock'

$LOADED_FEATURES << File.join(
  Gem.loaded_specs['webmock'].full_gem_path,
  'lib/webmock/http_lib_adapters/http_rb_adapter.rb'
)

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
