
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "delivery/version"

Gem::Specification.new do |spec|
  spec.name          = "delivery-sdk-ruby"
  spec.version       = Delivery::VERSION
  spec.authors       = ["Eric Dugre"]
  spec.email         = ["EricD@kentico.com"]

  spec.summary       = "Kentico Cloud Delivery SDK for Ruby"
  spec.description   = "Kentico Cloud Delivery SDK for Ruby"
  spec.homepage      = "https://github.com/Kentico/delivery-sdk-ruby"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/Kentico/delivery-sdk-ruby"
    spec.metadata["changelog_uri"] = "https://github.com/Kentico/delivery-sdk-ruby"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = Dir.glob("{bin,lib}/**/*") + %w(LICENSE.txt README.md)
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rest-client", "~> 2.0.2"
  spec.add_development_dependency "rspec", "~> 3.0"
end
