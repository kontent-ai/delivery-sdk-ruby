lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "delivery/version"

Gem::Specification.new do |spec|
  spec.name          = "kontent-delivery-sdk-ruby"
  spec.version       = Kentico::Kontent::Delivery::VERSION
  spec.authors       = ["Eric Dugre"]
  spec.email         = ["EricD@kentico.com"]

  spec.summary       = "Kentico Kontent Delivery SDK for Ruby"
  spec.description   = "Kentico Kontent Delivery SDK for Ruby"
  spec.homepage      = "https://github.com/Kentico/kontent-delivery-sdk-ruby"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/Kentico/kontent-delivery-sdk-ruby"
    spec.metadata["changelog_uri"] = "https://github.com/Kentico/kontent-delivery-sdk-ruby"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = Dir.glob("{bin,lib}/**/*") + %w(LICENSE.md README.md)
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency("dotenv", "~> 2.7", ">= 2.7.0")
  spec.add_runtime_dependency("nokogiri", "~> 1.11", ">= 1.11.0")
  spec.add_runtime_dependency("rest-client", "~> 2.1.0.rc1", ">= 2.1.0.rc1")
  spec.add_development_dependency("bundler", "~> 2.0")
  spec.add_development_dependency("rake", "~> 12.3", ">= 12.3.3")
  spec.add_development_dependency("rspec", "~> 3.8")
  spec.add_development_dependency("simplecov", "0.17.1", "< 0.18")
end
