# helper.rb

# webmock's http_rb adapter's require 'http' finds http.rb's lib/http.rb,
# takes HTTP::VERSION for the http gem's, and crashes trying to
# monkey-patch an HTTP::Client which isn't there.
def skip_webmocks_http_rb_adapter
  gem 'webmock'

  $LOADED_FEATURES << File.join(
    Gem.loaded_specs['webmock'].full_gem_path,
    'lib/webmock/http_lib_adapters/http_rb_adapter.rb'
  )
end

skip_webmocks_http_rb_adapter

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
