require_relative './lib/Eodhd/VERSION'

class Gem::Specification
  def dependencies=(gems)
    gems.each{|gem| add_dependency(*gem)}
  end

  def development_dependencies=(gems)
    gems.each{|gem| add_development_dependency(*gem)}
  end
end

Gem::Specification.new do |spec|
  spec.name = 'eodhd'
  spec.version = Eodhd::VERSION

  spec.summary = "Access the eodhd.com API with Ruby."
  spec.description = "Access the eodhd.com API with Ruby."

  spec.author = 'thoran'
  spec.email = 'code@thoran.com'
  spec.homepage = 'http://github.com/thoran/eodhd'
  spec.license = 'MIT'

  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.7'

  spec.files = [
    'eodhd.gemspec',
    Dir['lib/**/*.rb'],
    Dir['test/**/*'],
    'CHANGELOG',
    'Gemfile',
    'LICENSE',
    'Rakefile',
    'README.md',
  ].flatten

  spec.dependencies = %w{
    http.rb
    iodine
    logger
  }

  spec.development_dependencies = %w{
    rake
    minitest
    minitest-mock
    minitest-spec-context
    webmock
    vcr
    simplecov
  }
end
