# test/gemspec_test.rb

require_relative './helper'

%w{eodhd.rb eodhd}.each do |name|
  describe "#{name}.gemspec" do
    let(:spec){Gem::Specification.load(File.expand_path("../#{name}.gemspec", __dir__))}

    it "is a valid specification" do
      _(spec.validate).must_equal(true)
    end

    it "is named #{name}" do
      _(spec.name).must_equal(name)
    end

    it "does not pin a date" do
      _(spec.date).must_equal(Gem::Specification.new.date)
    end

    it "takes its version from Eodhd::VERSION" do
      _(spec.version.to_s).must_equal(Eodhd::VERSION)
    end

    it "declares its runtime dependencies" do
      _(spec.runtime_dependencies.collect(&:name).sort).must_equal(%w{http.rb iodine logger})
    end

    it "declares its development dependencies" do
      _(spec.development_dependencies.collect(&:name).sort).must_equal(%w{minitest minitest-mock minitest-spec-context rake simplecov vcr webmock})
    end

    it "ships the gemspec which names it" do
      _(spec.files).must_include("#{name}.gemspec")
    end
  end
end

# The second gemspec exists so that the gem resolves under both names, which is
# worth nothing if the two drift.  Each is loaded rather than the files compared,
# so that a difference is reported as the field it is.
describe 'the two gemspecs' do
  let(:bare){Gem::Specification.load(File.expand_path('../eodhd.gemspec', __dir__))}
  let(:dotted){Gem::Specification.load(File.expand_path('../eodhd.rb.gemspec', __dir__))}

  it "ship the same files but for the one naming each" do
    _(bare.files - ['eodhd.gemspec']).must_equal(dotted.files - ['eodhd.rb.gemspec'])
  end

  it "agree upon everything else declared" do
    fields = %i{version summary description authors email homepage licenses required_ruby_version require_paths}
    _(fields.collect{|field| bare.send(field).to_s}).must_equal(fields.collect{|field| dotted.send(field).to_s})
  end

  it "agree upon their dependencies" do
    _(bare.dependencies.collect(&:to_s).sort).must_equal(dotted.dependencies.collect(&:to_s).sort)
  end
end
